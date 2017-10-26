// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"
`include "can_testbench_defines.v"

module can_testbench();



parameter Tp = 1;
parameter BRP = 2*(`CAN_TIMING0_BRP + 1);
parameter FDBRMUL = 4; // 4* faster that BRP


reg         clk;
reg         rx;
wire        tx;
wire        tx_i;
wire        bus_off_on;
wire  [1:0] irqns;
wire        clkout;

wire        rx_and_tx;

integer     start_tb;
reg   [7:0] tmp_data;
reg         delayed_tx;
reg         tx_bypassed;
reg         extended_mode;

event       igor;

reg  [7:0] reg_data_in;
wire [7:0] reg_data_out;
reg  [7:0] reg_addr_read;
reg  [7:0] reg_addr_write;

wire [7:0] can1_reg_data_out;
wire [7:0] can2_reg_data_out;

reg        reg_rst;
reg        reg_re;
reg        reg_we;
reg  [1:0] reg_devmsk;

assign reg_data_out = reg_devmsk[0] ? can1_reg_data_out : (reg_devmsk[1] ? can2_reg_data_out : 8'hzz);

function irq;
input [1:0] devmsk;
  begin
    irq = |(~irqns & devmsk);
  end
endfunction

reg can1_isolate_rx;

// Instantiate can_top module
can_top_raw i_can_top
( 
  .reg_we_i(reg_we & reg_devmsk[0]),
  .reg_re_i(reg_re & reg_devmsk[0]),
  .reg_data_in(reg_data_in),
  .reg_data_out(can1_reg_data_out),
  .reg_addr_read_i(reg_addr_read),
  .reg_addr_write_i(reg_addr_write),
  .reg_rst_i(reg_rst),

  .clk_i(clk),
  .rx_i(can1_isolate_rx ? tx_i : rx_and_tx),
  .tx_o(tx_i),
  .bus_off_on(bus_off_on),
  .irq_on(irqns[0]),
  .clkout_o(clkout)

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  .mbist_si_i(1'b0),       // bist scan serial in
  .mbist_so_o(),           // bist scan serial out
  .mbist_ctrl_i(3'b001)    // mbist scan {enable, clock, reset}
`endif
);


// Instantiate can_top module 2
can_top_raw i_can_top2
( 
  .reg_we_i(reg_we && reg_devmsk[1]),
  .reg_re_i(reg_re && reg_devmsk[1]),
  .reg_data_in(reg_data_in),
  .reg_data_out(can2_reg_data_out),
  .reg_addr_read_i(reg_addr_read),
  .reg_addr_write_i(reg_addr_write),
  .reg_rst_i(reg_rst),

  .clk_i(clk),
  .rx_i(rx_and_tx),
  .tx_o(tx2_i),
  .bus_off_on(bus_off2_on),
  .irq_on(irqns[1]),
  .clkout_o(clkout)

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  .mbist_si_i(1'b0),       // bist scan serial in
  .mbist_so_o(),           // bist scan serial out
  .mbist_ctrl_i(3'b001)    // mbist scan {enable, clock, reset}
`endif
);


// Combining tx with the output enable signal.
wire tx_tmp1;
wire tx_tmp2;

assign tx_tmp1 = bus_off_on?  tx_i  : 1'b1;
assign tx_tmp2 = bus_off2_on? tx2_i : 1'b1;

assign tx = tx_tmp1 & tx_tmp2;

initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

`include "can_testbench_tests.v"


// Generate clock signal 25 MHz
// Generate clock signal 16 MHz
initial
begin
  clk=0;
  //forever #20 clk = ~clk;
  forever #31.25 clk = ~clk;
end


initial
begin
  can1_isolate_rx = 1'b0;
  start_tb = 1'b0;
  reg_re = 1'b0;
  reg_we = 1'b0;
  reg_devmsk = 1'bx;
  reg_data_in = 'hx;
  reg_addr_read = 'hx;
  reg_addr_write = 'hx;
  rx = 1;
  extended_mode = 0;
  tx_bypassed = 0;
  reg_rst = 1;
  #200 reg_rst = 0;
  #200 start_tb = 1;
end


// Generating delayed tx signal (CAN transciever delay)
always
begin
  wait (tx);
  repeat (2*BRP) @ (posedge clk);   // 4 time quants delay
  #1 delayed_tx = tx;
  wait (~tx);
  repeat (2*BRP) @ (posedge clk);   // 4 time quants delay
  #1 delayed_tx = tx;
end

//assign rx_and_tx = rx & delayed_tx;   FIX ME !!!
assign rx_and_tx = rx & (delayed_tx | tx_bypassed);   // When this signal is on, tx is not looped back to the rx.


// Main testbench
initial
begin
  wait(start_tb);

  // Set bus timing register 0
  write_register_impl(2'h3, 8'd6, {`CAN_TIMING0_SJW, `CAN_TIMING0_BRP});

  // Set bus timing register 1
  write_register_impl(2'h3, 8'd7, {`CAN_TIMING1_SAM, `CAN_TIMING1_TSEG2, `CAN_TIMING1_TSEG1});


  // Set Clock Divider register
//  extended_mode = 1'b1;
  // set mode, enable RX irq
  write_register_impl(2'h3, 8'd31, {extended_mode, 1'b1, 2'h0, 1'b0, 3'h0});


  // Set Acceptance Code and Acceptance Mask registers (their address differs for basic and extended mode
  if (extended_mode)
    begin
      write_register_impl(2'h3, 8'd16, 8'ha6); // acceptance code 0
      write_register_impl(2'h3, 8'd17, 8'hb0); // acceptance code 1
      write_register_impl(2'h3, 8'd18, 8'h12); // acceptance code 2
      write_register_impl(2'h3, 8'd19, 8'h30); // acceptance code 3
      write_register_impl(2'h3, 8'd20, 8'hff); // acceptance mask 0
      write_register_impl(2'h3, 8'd21, 8'hff); // acceptance mask 1
      write_register_impl(2'h3, 8'd22, 8'hff); // acceptance mask 2
      write_register_impl(2'h3, 8'd23, 8'hff); // acceptance mask 3
    end
  else
    begin
      write_register_impl(2'h3, 8'd4, 8'he8); // acceptance code
      write_register_impl(2'h3, 8'd5, 8'hff); // acceptance mask
    end

  #10;
  repeat (1000) @ (posedge clk);

  // Switch-off reset mode, enable all interrupts
  write_register_impl(2'h3, 8'd0, 8'b00011110);

  repeat (BRP) @ (posedge clk);   // At least BRP clocks needed before bus goes to dominant level. Otherwise 1 quant difference is possible
                                  // This difference is resynchronized later.

  // After exiting the reset mode sending bus free
  repeat (11) send_bit(1);

  //test_simple_recv;
//  test_synchronization;       // test currently switched off
//  test_empty_fifo_ext;        // test currently switched off
//  test_full_fifo_ext;         // test currently switched off
//  send_frame_ext;             // test currently switched off
//  test_empty_fifo;            // test currently switched off
//  test_full_fifo;             // test currently switched off
//  test_reset_mode;              // test currently switched off
//  bus_off_test;               // test currently switched off
//  forced_bus_off;             // test currently switched off
  //send_frame_basic;           // test currently switched on
//  send_frame_extended;        // test currently switched off
//  self_reception_request;       // test currently switched off
//  manual_frame_basic;         // test currently switched off
//  manual_frame_ext;           // test currently switched off
//    error_test;
//    register_test;
//    bus_off_recovery_test;
    //manual_fd_frame_basic_rcv;
    //send_into_fd_frame;
    test_tx_after_fdf;


/*
  #5000;
  $display("\n\nStart rx/tx err cnt\n");
  -> igor;
 
  // Switch-off reset mode
  $display("Rest mode ON");
  write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

  $display("Set extended mode");
  extended_mode = 1'b1;
  write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the extended mode

  $display("Rest mode OFF");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  write_register(8'd14, 8'hde); // rx err cnt
  write_register(8'd15, 8'had); // tx err cnt

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-on reset mode
  $display("Switch-on reset mode");
  write_register(8'd0, {7'h0, `CAN_MODE_RESET});

  write_register(8'd14, 8'h12); // rx err cnt
  write_register(8'd15, 8'h34); // tx err cnt

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-off reset mode
  $display("Switch-off reset mode");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt

  // Switch-on reset mode
  $display("Switch-on reset mode");
  write_register(8'd0, {7'h0, `CAN_MODE_RESET});

  write_register(8'd14, 8'h56); // rx err cnt
  write_register(8'd15, 8'h78); // tx err cnt

  // Switch-off reset mode
  $display("Switch-off reset mode");
  write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

  read_register(8'd14, tmp_data); // rx err cnt
  read_register(8'd15, tmp_data); // tx err cnt
*/
  #1000;
  $display("CAN Testbench finished !");
  $finish;
end

//------------------------------------------------------------------------------

/*
task initialize_fifo;
  integer i;
  begin
    for (i=0; i<32; i=i+1)
      begin
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.length_info[i] = 0;
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun_info[i] = 0;
      end

    for (i=0; i<64; i=i+1)
      begin
        can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo[i] = 0;
      end

    $display("(%0t) Fifo initialized", $time);
  end
endtask
*/
//------------------------------------------------------------------------------

/*
task read_overrun_info;
  input [4:0] start_addr;
  input [4:0] end_addr;
  integer i;
  begin
    for (i=start_addr; i<=end_addr; i=i+1)
      begin
        $display("len[0x%0x]=0x%0x", i, can_testbench.i_can_top.i_can_bsp.i_can_fifo.length_info[i]);
        $display("overrun[0x%0x]=0x%0x\n", i, can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun_info[i]);
      end
  end
endtask
*/
//------------------------------------------------------------------------------

task fifo_info;   // Displaying how many packets and how many bytes are in fifo. Not working when wr_info_pointer is smaller than rd_info_pointer.
  begin
      $display("(%0t) Currently %0d bytes in fifo (%0d packets)", $time, can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_cnt, 
      (can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr_info_pointer - can_testbench.i_can_top.i_can_bsp.i_can_fifo.rd_info_pointer));
end
endtask
//------------------------------------------------------------------------------
//---   Utility functions
//------------------------------------------------------------------------------

task read_register_impl;
  input  [1:0] dev_addr;
  input  [7:0] reg_addr;
  output [7:0] data;
  begin
    @ (posedge clk);
    #1;
    reg_devmsk = dev_addr;
    #1;
    reg_addr_read = reg_addr;
    reg_re = 1'b1;
    @ (posedge clk);
    @ (posedge clk); // testbench propagation delay ...
    $display("(%0t) Reading register #%d[%0d] = 0x%0x", $time, dev_addr, reg_addr, reg_data_out);
    data = reg_data_out;
    #1;
    reg_addr_read = 'hx;
    reg_re = 1'b0;
    reg_devmsk = 1'bx;
  end
endtask
//------------------------------------------------------------------------------

task write_register_impl;
  input [1:0] dev_addr;
  input [7:0] reg_addr;
  input [7:0] reg_data;

  begin
    $display("(%0t) Writing register #%d[%0d] with 0x%0x", $time, dev_addr, reg_addr, reg_data);
    @ (posedge clk);
    #1;
    reg_devmsk = dev_addr;
    #1;
    reg_addr_write = reg_addr;
    reg_data_in = reg_data;
    reg_we = 1'b1;
    @ (posedge clk);
    #10;
    reg_we = 1'b0;
    reg_addr_write = 'hx;
    reg_data_in = 'hx;
    reg_devmsk = 'hx;
  end
endtask
//------------------------------------------------------------------------------

task read_register;
  input  [7:0] reg_addr;
  output [7:0] reg_data;
  begin
    read_register_impl(2'h1, reg_addr, reg_data);
  end
endtask
//------------------------------------------------------------------------------

task read_register2;
  input  [7:0] reg_addr;
  output [7:0] reg_data;
  begin
    read_register_impl(2'h2, reg_addr, reg_data);
  end
endtask
//------------------------------------------------------------------------------

task write_register;
  input [7:0] reg_addr;
  input [7:0] reg_data;
  begin
    write_register_impl(2'h1, reg_addr, reg_data);
  end
endtask
//------------------------------------------------------------------------------

task write_register2;
  input [7:0] reg_addr;
  input [7:0] reg_data;
  begin
    write_register_impl(2'h2, reg_addr, reg_data);
  end
endtask
//------------------------------------------------------------------------------

task read_receive_buffer;
  integer i;
  begin
    $display("\n\n(%0t)", $time);
    if(extended_mode)   // Extended mode
      begin
        for (i=8'd16; i<=8'd28; i=i+1)
          read_register(i, tmp_data);
        //if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun)
        //  $display("\nWARNING: Above packet was received with overrun.");
      end
    else
      begin
        for (i=8'd20; i<=8'd29; i=i+1)
          read_register(i, tmp_data);
        //if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.overrun)
        //  $display("\nWARNING: Above packet was received with overrun.");
      end
  end
endtask
//------------------------------------------------------------------------------

task release_rx_buffer_command;
  begin
    write_register(8'd1, 8'h4);
    $display("(%0t) Rx buffer released.", $time);
  end
endtask
//------------------------------------------------------------------------------

task tx_request_command_impl;
  input [1:0] msk;
  begin
    write_register_impl(msk, 8'd1, 8'h1);
    $display("(%0t) #%h: Tx requested.", $time, msk);
  end
endtask
//------------------------------------------------------------------------------

task tx_request_command;
  tx_request_command_impl(2'h1);
endtask
//------------------------------------------------------------------------------

task tx_request_command2;
  tx_request_command_impl(2'h2);
endtask
//------------------------------------------------------------------------------

task tx_abort_command;
  begin
    write_register(8'd1, 8'h2);
    $display("(%0t) Tx abort requested.", $time);
  end
endtask
//------------------------------------------------------------------------------

task clear_data_overrun_command;
  begin
    write_register(8'd1, 8'h8);
    $display("(%0t) Data overrun cleared.", $time);
  end
endtask
//------------------------------------------------------------------------------

task self_reception_request_command;
  begin
    write_register(8'd1, 8'h10);
    $display("(%0t) Self reception requested.", $time);
  end
endtask
//------------------------------------------------------------------------------

task send_bit;
  input bit;
  begin
    #1 rx=bit;
    repeat ((`CAN_TIMING1_TSEG1 + `CAN_TIMING1_TSEG2 + 3)*BRP) @ (posedge clk);
    if (rx_and_tx != bit) begin
      $display("send_bit arbitration lost!");
      $stop;
    end
  end
endtask

task wait_bit;
  begin
    repeat ((`CAN_TIMING1_TSEG1 + `CAN_TIMING1_TSEG2 + 3)*BRP) @ (posedge clk);
  end
endtask
//------------------------------------------------------------------------------

task send_bits;
  input integer cnt;
  input [1023:0] data;
  integer c;
  begin
    for (c=cnt; c > 0; c=c-1)
      send_bit(data[c-1]);
  end
endtask
//------------------------------------------------------------------------------

task send_fd_bit;
  input bit;
  integer cnt;
  begin
    #1 rx=bit;
    repeat ((`CAN_TIMING1_TSEG1 + `CAN_TIMING1_TSEG2 + 3)*BRP/FDBRMUL) @ (posedge clk);
    if (rx_and_tx != bit) begin
      $display("send_fd_bit arbitration lost!");
      $stop;
    end
  end
endtask

task send_fd_bits;
  input integer cnt;
  input [1023:0] data;
  integer c;
  begin
    for (c=cnt; c > 0; c=c-1)
      send_fd_bit(data[c-1]);
  end
endtask
//------------------------------------------------------------------------------

task receive_frame;           // CAN IP core receives frames
  input mode;
  input remote_trans_req;
  input [28:0] id;
  input  [3:0] length;
  input [14:0] crc;

  reg [117:0] data;
  reg         previous_bit;
  reg         stuff;
  reg         tmp;
  reg         arbitration_lost;
  integer     pointer;
  integer     cnt;
  integer     total_bits;
  integer     stuff_cnt;

  begin

    stuff_cnt = 1;
    stuff = 0;

    if(mode)          // Extended format
      data = {id[28:18], 1'b1, 1'b1, id[17:0], remote_trans_req, 2'h0, length};
    else              // Standard format
      data = {id[10:0], remote_trans_req, 1'b0, 1'b0, length};

    if (~remote_trans_req)
      begin
        if(length)    // Send data if length is > 0
          begin
            for (cnt=1; cnt<=(2*length); cnt=cnt+1)  // data   (we are sending nibbles)
              data = {data[113:0], cnt[3:0]};
          end
      end

    // Adding CRC
    data = {data[104:0], crc[14:0]};


    // Calculating pointer that points to the bit that will be send
    if (remote_trans_req)
      begin
        if(mode)          // Extended format
          pointer = 52;
        else              // Standard format
          pointer = 32;
      end
    else
      begin
        if(mode)          // Extended format
          pointer = 52 + 8 * length;
        else              // Standard format
          pointer = 32 + 8 * length;
      end

    // This is how many bits we need to shift
    total_bits = pointer;

    // Waiting until previous msg is finished before sending another one
    if (arbitration_lost)           //  Arbitration lost. Another node is transmitting. We have to wait until it is finished.
      wait ( (~can_testbench.i_can_top.i_can_bsp.error_frame) & 
             (~can_testbench.i_can_top.i_can_bsp.rx_inter   ) & 
             (~can_testbench.i_can_top.i_can_bsp.tx_state   )
           );
    else                            // We were transmitter of the previous frame. No need to wait for another node to finish transmission.
      wait ( (~can_testbench.i_can_top.i_can_bsp.error_frame) & 
             (~can_testbench.i_can_top.i_can_bsp.rx_inter   )
           );
    arbitration_lost = 0;
    
    send_bit(0);                        // SOF
    previous_bit = 0;

    fork 

    begin
      for (cnt=0; cnt<=total_bits; cnt=cnt+1)
        begin
          if (stuff_cnt == 5)
            begin
              stuff_cnt = 1;
              total_bits = total_bits + 1;
              stuff = 1;
              tmp = ~data[pointer+1];
              send_bit(~data[pointer+1]);
              previous_bit = ~data[pointer+1];
            end
          else
            begin
              if (data[pointer] == previous_bit)
                stuff_cnt <= stuff_cnt + 1;
              else
                stuff_cnt <= 1;
              
              stuff = 0;
              tmp = data[pointer];
              send_bit(data[pointer]);
              previous_bit = data[pointer];
              pointer = pointer - 1;
            end
          if (arbitration_lost)
            cnt=total_bits+1;         // Exit the for loop
        end

        // Nothing send after the data (just recessive bit)
        repeat (13) send_bit(1);         // CRC delimiter + ack + ack delimiter + EOF + intermission= 1 + 1 + 1 + 7 + 3
    end

    begin
      while (mode ? (cnt<32) : (cnt<12))
        begin
          #1 wait (can_testbench.i_can_top.sample_point);
          if (mode)
            begin
              if (cnt<32 & tmp & (~rx_and_tx))
                begin
                  arbitration_lost = 1;
                  rx = 1;       // Only recessive is send from now on.
                end
            end
          else
            begin
              if (cnt<12 & tmp & (~rx_and_tx))
                begin
                  arbitration_lost = 1;
                  rx = 1;       // Only recessive is send from now on.
                end
            end
        end
    end

    join

  end
endtask
//------------------------------------------------------------------------------

// State machine monitor (btl)
always @ (posedge clk)
begin
  if(can_testbench.i_can_top.i_can_btl.go_sync & can_testbench.i_can_top.i_can_btl.go_seg1 | can_testbench.i_can_top.i_can_btl.go_sync & can_testbench.i_can_top.i_can_btl.go_seg2 | 
     can_testbench.i_can_top.i_can_btl.go_seg1 & can_testbench.i_can_top.i_can_btl.go_seg2)
    begin
      $display("(%0t) ERROR multiple go_sync, go_seg1 or go_seg2 occurance\n\n", $time);
      #1000;
      $stop;
    end

  if(can_testbench.i_can_top.i_can_btl.sync & can_testbench.i_can_top.i_can_btl.seg1 | can_testbench.i_can_top.i_can_btl.sync & can_testbench.i_can_top.i_can_btl.seg2 | 
     can_testbench.i_can_top.i_can_btl.seg1 & can_testbench.i_can_top.i_can_btl.seg2)
    begin
      $display("(%0t) ERROR multiple sync, seg1 or seg2 occurance\n\n", $time);
      #1000;
      $stop;
    end
end

/* stuff_error monitor (bsp)
always @ (posedge clk)
begin
  if(can_testbench.i_can_top.i_can_bsp.stuff_error)
    begin
      $display("\n\n(%0t) Stuff error occured in can_bsp.v file\n\n", $time);
      $stop; //                                     After everything is finished add another condition (something like & (~idle)) and enable stop
    end
end
//*/

//
// CRC monitor (used until proper CRC generation is used in testbench
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.rx_ack       &
      can_testbench.i_can_top.i_can_bsp.sample_point & 
      can_testbench.i_can_top.i_can_bsp.crc_err
     )
    $display("*E (%0t) ERROR: CRC error (Calculated crc = 0x%0x, crc_in = 0x%0x)", $time, can_testbench.i_can_top.i_can_bsp.calculated_crc, can_testbench.i_can_top.i_can_bsp.crc_in);
end
//------------------------------------------------------------------------------

/*
// overrun monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr & can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_full)
    $display("(%0t)overrun", $time);
end
*/


// form error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.form_err)
    $display("*E (%0t) ERROR: form_error", $time);
end



// acknowledge error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.ack_err)
    $display("*E (%0t) ERROR: acknowledge_error", $time);
end
//------------------------------------------------------------------------------

always @ (posedge clk)
begin
  //if (can_testbench.i_can_top.i_can_bsp.fdf_r)
  //  $display("*I (%0t) INFO: fdf_r", $time);
`ifdef CAN_FD_TOLERANT
  //if (can_testbench.i_can_top.i_can_bsp.fd_fall_edge_lstbtm)
//    $display("*I (%0t) INFO: fd_fall_edge_lstbtm", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_skip_fdf)
    $display("*I (%0t) INFO: go_rx_skip_fdf", $time);
`endif
  if (can_testbench.i_can_top.i_can_bsp.go_rx_idle)
    $display("*I (%0t) INFO: go_rx_idle", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_id1)
    $display("*I (%0t) INFO: go_rx_id1", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_rtr1)
    $display("*I (%0t) INFO: go_rx_rtr1", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_ide)
    $display("*I (%0t) INFO: go_rx_ide", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_id2)
    $display("*I (%0t) INFO: go_rx_id2", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_rtr2)
    $display("*I (%0t) INFO: go_rx_rtr2", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_r1)
    $display("*I (%0t) INFO: go_rx_r1", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_r0)
    $display("*I (%0t) INFO: go_rx_r0", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_dlc)
    $display("*I (%0t) INFO: go_rx_dlc", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_data)
    $display("*I (%0t) INFO: go_rx_data", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_crc)
    $display("*I (%0t) INFO: go_rx_crc", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_crc_lim)
    $display("*I (%0t) INFO: go_rx_crc_lim", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_ack)
    $display("*I (%0t) INFO: go_rx_ack", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_ack_lim)
    $display("*I (%0t) INFO: go_rx_ack_lim", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_eof)
    $display("*I (%0t) INFO: go_rx_eof", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_rx_inter)
    $display("*I (%0t) INFO: go_rx_inter", $time);

  if (can_testbench.i_can_top.i_can_bsp.go_overload_frame)
    $display("*I (%0t) INFO: go_overload_frame", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_error_frame)
    $display("*I (%0t) INFO: go_error_frame", $time);
  if (can_testbench.i_can_top.i_can_bsp.go_tx)
    $display("*I (%0t) INFO: go_tx", $time);
  if (can_testbench.i_can_top.i_can_bsp.error_frame_ended)
    $display("*I (%0t) INFO: error_frame_ended", $time);

  //if (can_testbench.i_can_top.i_can_bsp.fd_fall_edge_raw)
//    $display("*I (%0t) INFO: fd_fall_edge_raw", $time);


    //if (can_testbench.i_can_top.i_can_bsp.bus_free_cnt_en)
  //  $display("*I (%0t) INFO: bus_free_cnt_en", $time);
end

/*
// bit error monitor
always @ (posedge clk)
begin
  if (can_testbench.i_can_top.i_can_bsp.bit_err)
    $display("*E (%0t) ERROR: bit_error", $time);
end
*/

/*
task manual_send_frame;
  input []
  begin

  end
*/
//------------------------------------------------------------------------------




endmodule

