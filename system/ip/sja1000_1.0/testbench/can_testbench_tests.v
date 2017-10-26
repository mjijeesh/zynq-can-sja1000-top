task test_simple_recv;
  reg [2:0]  txd;
  reg [2:0]  rxd;
begin
    txd = 2'h2;
    rxd = 2'h1;
    write_register_impl(txd, 8'd10, 8'hea); // Writing ID[10:3] = 0xea
    write_register_impl(txd, 8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
    write_register_impl(txd, 8'd12, 8'h56); // data byte 1
    write_register_impl(txd, 8'd13, 8'h78); // data byte 2
    write_register_impl(txd, 8'd14, 8'h9a); // data byte 3
    write_register_impl(txd, 8'd15, 8'hbc); // data byte 4
    write_register_impl(txd, 8'd16, 8'hde); // data byte 5
    write_register_impl(txd, 8'd17, 8'hf0); // data byte 6
    write_register_impl(txd, 8'd18, 8'h0f); // data byte 7
    write_register_impl(txd, 8'd19, 8'hed); // data byte 8

    // Enable irqs (basic mode)
    write_register_impl(2'h3, 8'd0, 8'h1e);

    tx_request_command_impl(txd);

    wait (irq(txd));
    $display("IRQ from TX caught");
    read_receive_buffer;
    release_rx_buffer_command;
end
endtask

task bus_off_recovery_test;
  begin
    -> igor;

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    write_register(8'd16, 8'h00); // acceptance code 0
    write_register(8'd17, 8'h00); // acceptance code 1
    write_register(8'd18, 8'h00); // acceptance code 2
    write_register(8'd19, 8'h00); // acceptance code 3
    write_register(8'd20, 8'hff); // acceptance mask 0
    write_register(8'd21, 8'hff); // acceptance mask 1
    write_register(8'd22, 8'hff); // acceptance mask 2
    write_register(8'd23, 8'hff); // acceptance mask 3

    write_register2(8'd16, 8'h00); // acceptance code 0
    write_register2(8'd17, 8'h00); // acceptance code 1
    write_register2(8'd18, 8'h00); // acceptance code 2
    write_register2(8'd19, 8'h00); // acceptance code 3
    write_register2(8'd20, 8'hff); // acceptance mask 0
    write_register2(8'd21, 8'hff); // acceptance mask 1
    write_register2(8'd22, 8'hff); // acceptance mask 2
    write_register2(8'd23, 8'hff); // acceptance mask 3

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // Enable all interrupts
    write_register(8'd4, 8'hff); // irq enable register

    repeat (30) send_bit(1);
    -> igor;
    $display("(%0t) CAN should be idle now", $time);

    // Node 2 sends a message
    write_register2(8'd16, 8'h83); // tx registers
    write_register2(8'd17, 8'h12); // tx registers
    write_register2(8'd18, 8'h34); // tx registers
    write_register2(8'd19, 8'h45); // tx registers
    write_register2(8'd20, 8'h56); // tx registers
    write_register2(8'd21, 8'hde); // tx registers
    write_register2(8'd22, 8'had); // tx registers
    write_register2(8'd23, 8'hbe); // tx registers

    write_register2(8'd1, 8'h1);  // tx request

    // Wait until node 1 receives rx irq
    read_register(8'd3, tmp_data);
    while (!(tmp_data & 8'h01)) begin
      read_register(8'd3, tmp_data);
    end

    $display("Frame received by node 1.");

    // Node 1 will send a message and will receive many errors
    write_register(8'd16, 8'haa); // tx registers
    write_register(8'd17, 8'haa); // tx registers
    write_register(8'd18, 8'haa); // tx registers
    write_register(8'd19, 8'haa); // tx registers
    write_register(8'd20, 8'haa); // tx registers
    write_register(8'd21, 8'haa); // tx registers
    write_register(8'd22, 8'haa); // tx registers
    write_register(8'd23, 8'haa); // tx registers

    fork
      begin
        write_register(8'd1, 8'h1);  // tx request
      end

      begin
        // Waiting until node 1 starts transmitting
        wait (!tx_i);
        repeat (33) send_bit(1);
        repeat (330) send_bit(0);
        repeat (1) send_bit(1);
      end

    join

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    repeat (1999) send_bit(1);

    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    write_register(8'd14, 8'h0); // rx err cnt

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});


    // Wait some time before simulation ends
    repeat (10000) @ (posedge clk);
  end
endtask // bus_off_recovery_test
//------------------------------------------------------------------------------

task error_test;
  begin
    // Switch-off reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    // Set error warning limit register
    write_register(8'd13, 8'h56); // error warning limit

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // Enable all interrupts
    write_register(8'd4, 8'hff); // irq enable register

    repeat (300) send_bit(0);

    $display("Kr neki");

  end
endtask
//------------------------------------------------------------------------------

task register_test;
  integer i, j, tmp;
  begin
    $display("Change mode to extended mode and test registers");
    // Switch-off reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)
    write_register2(8'd31, {extended_mode, 3'h0, 1'b0, 3'h0});   // Setting the normal mode (not extended)

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    for (i=1; i<128; i=i+1) begin
      for (j=0; j<8; j=j+1) begin
        read_register(i, tmp_data);
        write_register(i, tmp_data | (1 << j));
      end
    end

  end
endtask
//------------------------------------------------------------------------------

task forced_bus_off;    // Forcing bus-off by writinf to tx_err_cnt register
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Set Clock Divider register
    write_register(8'd31, {1'b1, 7'h0});    // Setting the extended mode (not normal)

    // Write 255 to tx_err_cnt register - Forcing bus-off
    write_register(8'd15, 255);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

//    #1000000;
    #2500000;


    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Write 245 to tx_err_cnt register
    write_register(8'd15, 245);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    #1000000;


  end
endtask   // forced_bus_off
//------------------------------------------------------------------------------

task manual_frame_basic;    // Testbench sends a basic format frame
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd4, 8'h28); // acceptance code
    write_register(8'd5, 8'hff); // acceptance mask

    repeat (100) @ (posedge clk);

    // Switch-off reset mode
//    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register(8'd0, 8'h1e);  // reset_off, all irqs enabled.

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);

    write_register(8'd10, 8'h55); // Writing ID[10:3] = 0x55
    write_register(8'd11, 8'h77); // Writing ID[2:0] = 0x3, rtr = 1, length = 7
    write_register(8'd12, 8'h00); // data byte 1
    write_register(8'd13, 8'h00); // data byte 2
    write_register(8'd14, 8'h00); // data byte 3
    write_register(8'd15, 8'h00); // data byte 4
    write_register(8'd16, 8'h00); // data byte 5
    write_register(8'd17, 8'h00); // data byte 6
    write_register(8'd18, 8'h00); // data byte 7
    write_register(8'd19, 8'h00); // data byte 8

    tx_bypassed = 0;    // When this signal is on, tx is not looped back to the rx.


    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #931;


        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID arbi lost
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC stuff
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC  stuff
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#400;

          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat



      end


    join



    read_receive_buffer;
    release_rx_buffer_command;

    #1000 read_register(8'd3, tmp_data);
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

// First we receive a msg
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER





    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #931;


        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID arbi lost
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#6000;

          send_bit(0);  // SOF
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 6
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 5
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC b
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat



      end


    join



    read_receive_buffer;
    release_rx_buffer_command;

    #1000 read_register(8'd3, tmp_data);
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #4000000;

  end
endtask   //  manual_frame_basic
//------------------------------------------------------------------------------

task manual_frame_ext;    // Testbench sends an extended format frame
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode

    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'h00); // acceptance code 1
    write_register(8'd18, 8'h5a); // acceptance code 2
    write_register(8'd19, 8'hac); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3

//write_register(8'd14, 8'h7a); // rx err cnt
//write_register(8'd15, 8'h7a); // tx err cnt

//read_register(8'd14, tmp_data); // rx err cnt
//read_register(8'd15, tmp_data); // tx err cnt

    repeat (100) @ (posedge clk);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


    // Extended frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'h00);   // ID[20:13] = 00
    write_register(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register(8'd20, 8'ha8);   // ID[4:0]   = 15
    // write_register(8'd21, 8'h78); RTR does not send any data
    // write_register(8'd22, 8'h9a);
    // write_register(8'd23, 8'hbc);
    // write_register(8'd24, 8'hde);
    // write_register(8'd25, 8'hf0);
    // write_register(8'd26, 8'h0f);
    // write_register(8'd27, 8'hed);
    // write_register(8'd28, 8'hcb);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);

    // tx_bypassed = 1;    // When this signal is on, tx is not looped back to the rx.

    fork
      begin
        tx_request_command;
//        self_reception_request_command;
      end

      begin
        #771;

        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID 6
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 5   // Force arbitration lost
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 6
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC f
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC 2
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC a
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
#80;
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID 6
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID
          send_bit(0);  // ID     // Force arbitration lost
          send_bit(0);  // ID
          send_bit(1);  // ID 5
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 0
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC stuff
          send_bit(0);  // CRC
          send_bit(0);  // CRC 0
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC e
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC c
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER

#80;
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID 6
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // RTR
          send_bit(1);  // IDE
          send_bit(0);  // ID 0
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID 0
          send_bit(1);  // ID stuff
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID 6
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID a
          send_bit(1);  // ID 1
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID 5
          send_bit(1);  // RTR
          send_bit(0);  // r1
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC 4
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC d
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC 3
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC 9
          send_bit(1);  // CRC DELIM
          send_bit(0);  // ACK
          send_bit(1);  // ACK DELIM
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // EOF
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat


      end

    join



    read_receive_buffer;
    release_rx_buffer_command;

    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    // Read irq register
    #1 read_register(8'd3, tmp_data);

    // Read error code capture register
    read_register(8'd12, tmp_data);

    // Read error capture code register
//    read_register(8'd12, tmp_data);

read_register(8'd14, tmp_data); // rx err cnt
read_register(8'd15, tmp_data); // tx err cnt

    #4000000;

  end
endtask   //  manual_frame_ext
//------------------------------------------------------------------------------

task bus_off_test;    // Testbench sends a frame
  begin
    write_register(8'd10, 8'he8); // Writing ID[10:3] = 0xe8
    write_register(8'd11, 8'hb7); // Writing ID[2:0] = 0x5, rtr = 1, length = 7
    write_register(8'd12, 8'h00); // data byte 1
    write_register(8'd13, 8'h00); // data byte 2
    write_register(8'd14, 8'h00); // data byte 3
    write_register(8'd15, 8'h00); // data byte 4
    write_register(8'd16, 8'h00); // data byte 5
    write_register(8'd17, 8'h00); // data byte 6
    write_register(8'd18, 8'h00); // data byte 7
    write_register(8'd19, 8'h00); // data byte 8

    fork
      begin
        tx_request_command;
      end

      begin
        #2000;

        repeat (16)
        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC DELIM
          send_bit(1);  // ACK            ack error
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
        end // repeat

        // Node is error passive now.

        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);

->igor;

        repeat (34)

        begin
          send_bit(0);  // SOF
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(0);  // ID
          send_bit(1);  // ID
          send_bit(1);  // RTR
          send_bit(0);  // IDE
          send_bit(0);  // r0
          send_bit(0);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // DLC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(0);  // CRC
          send_bit(0);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC
          send_bit(1);  // CRC DELIM
          send_bit(1);  // ACK            ack error
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(0);  // ERROR
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // ERROR DELIM
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // INTER
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
          send_bit(1);  // SUSPEND
        end // repeat

->igor;

        // Node is bus-off now


        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);



        #100000;

        // Switch-off reset mode
        write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

        repeat (64 * 11)
        begin
          send_bit(1);
        end // repeat

        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);

        repeat (64 * 11)
        begin
          send_bit(1);
        end // repeat

        // Read irq register (error interrupt should be cleared now.
        read_register(8'd3, tmp_data);
      end
    join

    fork
      begin
        tx_request_command;
      end

      begin
        #1100;

        send_bit(1);    // To spend some time before transmitter is ready.

        repeat (1)
        begin
          send_bit(0);  // SOF
          send_bits(11, 11'b11101000101);      // ID
          send_bits(3,   3'b100);              // RTR, IDE, r0
          send_bits(4,   4'b0111);             // DLC
          send_bits(15, 15'b100111010011111);  // CRC
          send_bit(1);                         // CRC DELIM
          send_bit(0);                         // ACK
          send_bit(1);                         // ACK DELIM
          send_bits(7,   7'b1111111);          // EOF
          send_bits(3,   3'b111);              // INTER
        end // repeat
      end

    join

    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #4000000;

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc

    #1000000;

  end
endtask   // bus_off_test
//------------------------------------------------------------------------------

task send_frame_basic;    // CAN IP core sends frames
  begin
    write_register(8'd10, 8'hea); // Writing ID[10:3] = 0xea
    write_register(8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
    write_register(8'd12, 8'h56); // data byte 1
    write_register(8'd13, 8'h78); // data byte 2
    write_register(8'd14, 8'h9a); // data byte 3
    write_register(8'd15, 8'hbc); // data byte 4
    write_register(8'd16, 8'hde); // data byte 5
    write_register(8'd17, 8'hf0); // data byte 6
    write_register(8'd18, 8'h0f); // data byte 7
    write_register(8'd19, 8'hed); // data byte 8

    // Enable irqs (basic mode)
    write_register(8'd0, 8'h1e);

    fork
      begin
        #1100;
        $display("\n\nStart receiving data from CAN bus");
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h0, 15'h6cea); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h2, 15'h7b4a); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000ee, 3'h1}, 4'h1, 15'h00c5); // mode, rtr, id, length, crc
      end

      begin
        tx_request_command;
      end

      begin
        wait (can_testbench.i_can_top.i_can_bsp.go_tx)        // waiting for tx to start
        wait (~can_testbench.i_can_top.i_can_bsp.need_to_tx)  // waiting for tx to finish
        tx_request_command;                                   // start another tx
      end

      begin
        // Transmitting acknowledge (for first packet)
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;

        // Transmitting acknowledge (for second packet)
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;
      end


    join

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #200000;

    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // send_frame_basic
//------------------------------------------------------------------------------

task send_frame_extended;    // CAN IP core sends basic or extended frames in extended mode
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode
    write_register2(8'd31, {extended_mode, 7'h0});    // Setting the extended mode

    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'hb0); // acceptance code 1
    write_register(8'd18, 8'h12); // acceptance code 2
    write_register(8'd19, 8'h30); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3

    write_register2(8'd16, 8'ha6); // acceptance code 0
    write_register2(8'd17, 8'hb0); // acceptance code 1
    write_register2(8'd18, 8'h12); // acceptance code 2
    write_register2(8'd19, 8'h30); // acceptance code 3
    write_register2(8'd20, 8'h00); // acceptance mask 0
    write_register2(8'd21, 8'h00); // acceptance mask 1
    write_register2(8'd22, 8'h00); // acceptance mask 2
    write_register2(8'd23, 8'h00); // acceptance mask 3

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register2(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


/*  Basic frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'h45);   // Frame format = 0, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'ha0);   // ID[20:18] = 5
    // write_register(8'd19, 8'h78); RTR does not send any data
    // write_register(8'd20, 8'h9a);
    // write_register(8'd21, 8'hbc);
    // write_register(8'd22, 8'hde);
    // write_register(8'd23, 8'hf0);
    // write_register(8'd24, 8'h0f);
    // write_register(8'd25, 8'hed);
    // write_register(8'd26, 8'hcb);
    // write_register(8'd27, 8'ha9);
    // write_register(8'd28, 8'h87);
*/

    // Extended frame format
    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'h00);   // ID[20:13] = 00
    write_register(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register(8'd20, 8'ha8);   // ID[4:0]   = 15
    write_register2(8'd16, 8'hc5);   // Frame format = 1, Remote transmision request = 1, DLC = 5
    write_register2(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register2(8'd18, 8'h00);   // ID[20:13] = 00
    write_register2(8'd19, 8'h5a);   // ID[12:5]  = 5a
    write_register2(8'd20, 8'ha8);   // ID[4:0]   = 15
    // write_register(8'd21, 8'h78); RTR does not send any data
    // write_register(8'd22, 8'h9a);
    // write_register(8'd23, 8'hbc);
    // write_register(8'd24, 8'hde);
    // write_register(8'd25, 8'hf0);
    // write_register(8'd26, 8'h0f);
    // write_register(8'd27, 8'hed);
    // write_register(8'd28, 8'hcb);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);
    write_register2(8'd4, 8'hff);


    fork
      begin
        #1251;
        $display("\n\nStart receiving data from CAN bus");
        /* Standard frame format
        receive_frame(0, 0, {26'h00000a0, 3'h1}, 4'h1, 15'h2d9c); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000a0, 3'h1}, 4'h2, 15'h46b4); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h0, 15'h42cd); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h1, 15'h555f); // mode, rtr, id, length, crc
        receive_frame(0, 0, {26'h00000af, 3'h1}, 4'h2, 15'h6742); // mode, rtr, id, length, crc
        */

        // Extended frame format
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h14}, 4'h1, 15'h1528); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h2, 15'h3d2d); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h0, 15'h23aa); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h1, 15'h2d22); // mode, rtr, id, length, crc
        receive_frame(1, 0, {8'ha6, 8'h00, 8'h5a, 5'h15}, 4'h2, 15'h3d2d); // mode, rtr, id, length, crc

      end

      begin
        tx_request_command;
      end

      begin
        // Transmitting acknowledge
        wait (can_testbench.i_can_top.i_can_bsp.tx_state & can_testbench.i_can_top.i_can_bsp.rx_ack & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 0;
        wait (can_testbench.i_can_top.i_can_bsp.rx_ack_lim & can_testbench.i_can_top.i_can_bsp.tx_point);
        #1 rx = 1;
      end

      begin   // Reading irq and arbitration lost capture register
        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read irq register
            #1 read_register(8'd3, tmp_data);

            // Read arbitration lost capture register
            read_register(8'd11, tmp_data);
          end

        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read irq register
            #1 read_register(8'd3, tmp_data);
          end

        repeat(1)
          begin
            while (~(can_testbench.i_can_top.i_can_bsp.rx_crc_lim & can_testbench.i_can_top.i_can_bsp.sample_point))
              begin
                @ (posedge clk);
              end

            // Read arbitration lost capture register
            read_register(8'd11, tmp_data);
          end

      end

      begin
        # 344000;

        // Switch-on reset mode
        $display("expect: SW reset ON\n");
        write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

        #40000;
        // Switch-off reset mode
        $display("expect: SW reset OFF\n");
        write_register(8'd0, {7'h0, (~`CAN_MODE_RESET)});
      end

    join

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;

    #200000;

    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // send_frame_extended
//------------------------------------------------------------------------------

task self_reception_request;    // CAN IP core sends sets self reception mode and transmits a msg. This test runs in EXTENDED mode
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Clock Divider register
    extended_mode = 1'b1;
    write_register(8'd31, {extended_mode, 7'h0});    // Setting the extended mode

    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd16, 8'ha6); // acceptance code 0
    write_register(8'd17, 8'hb0); // acceptance code 1
    write_register(8'd18, 8'h12); // acceptance code 2
    write_register(8'd19, 8'h30); // acceptance code 3
    write_register(8'd20, 8'h00); // acceptance mask 0
    write_register(8'd21, 8'h00); // acceptance mask 1
    write_register(8'd22, 8'h00); // acceptance mask 2
    write_register(8'd23, 8'h00); // acceptance mask 3

    // Setting the "self test mode"
    write_register(8'd0, 8'h4);

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);


    // Writing TX frame information + identifier + data
    write_register(8'd16, 8'h45);   // Frame format = 0, Remote transmision request = 1, DLC = 5
    write_register(8'd17, 8'ha6);   // ID[28:21] = a6
    write_register(8'd18, 8'ha0);   // ID[20:18] = 5
    // write_register(8'd19, 8'h78); RTR does not send any data
    // write_register(8'd20, 8'h9a);
    // write_register(8'd21, 8'hbc);
    // write_register(8'd22, 8'hde);
    // write_register(8'd23, 8'hf0);
    // write_register(8'd24, 8'h0f);
    // write_register(8'd25, 8'hed);
    // write_register(8'd26, 8'hcb);
    // write_register(8'd27, 8'ha9);
    // write_register(8'd28, 8'h87);


    // Enabling IRQ's (extended mode)
    write_register(8'd4, 8'hff);

    self_reception_request_command;

    #400000;

    read_receive_buffer;
    release_rx_buffer_command;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;


    read_receive_buffer;

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask   // self_reception_request
//------------------------------------------------------------------------------

task test_empty_fifo;
  begin
    // Enable irqs (basic mode)
    write_register(8'd0, 8'h1e);

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h3, 15'h56a9); // mode, rtr, id, length, crc
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h7, 15'h391d); // mode, rtr, id, length, crc

    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc

    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
  end
endtask
//------------------------------------------------------------------------------

task test_empty_fifo_ext;
  begin
    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc

    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc

    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
  end
endtask
//------------------------------------------------------------------------------

task test_full_fifo;
  begin
    // Enable irqs (basic mode)
    // write_register(8'd0, 8'h1e);
    write_register(8'd0, 8'h10); // enable only overrun irq

    $display("\n\n");

    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h0, 15'h2372); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h1, 15'h30bb); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h2, 15'h2da1); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h3, 15'h56a9); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h4, 15'h3124); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h5, 15'h6944); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h6, 15'h5182); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h7, 15'h391d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
    $display("FIFO should be full now");
    $display("2 packets won't be received because of the overrun. IRQ should be set");

    // Following one is accepted with overrun
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    // Following one is accepted with overrun
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    $display("Now we'll release 1 packet.");
    release_rx_buffer_command;
    fifo_info;

    // Space just enough for the following frame.
    $display("Getting 1 small packet (just big enough). Fifo is full again");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h0, 15'h2372); // mode, rtr, id, length, crc
    fifo_info;

    // Following accepted with overrun
    $display("1 packets won't be received because of the overrun. IRQ should be set");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;

    // Following accepted with overrun
    $display("1 packets won't be received because of the overrun. IRQ should be set");
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);

    $display("Releasing 3 packets.");
    release_rx_buffer_command;
    release_rx_buffer_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;
    receive_frame(0, 0, {26'h00000e8, 3'h1}, 4'h8, 15'h70e0); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);
    $display("\n\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    clear_data_overrun_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    clear_data_overrun_command;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    // Read irq register
    read_register(8'd3, tmp_data);

    // Read irq register
    read_register(8'd3, tmp_data);
    #1000;

  end
endtask
//------------------------------------------------------------------------------

task test_full_fifo_ext;
  begin
    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;

    receive_frame(1, 0, 29'h14d60246, 4'h0, 15'h6f54); // mode, rtr, id, length, crc
    read_receive_buffer;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h1, 15'h6d38); // mode, rtr, id, length, crc
    read_receive_buffer;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h2, 15'h053e); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h4, 15'h4bba); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h6, 15'h6f40); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 10);

    release_rx_buffer_command;
    release_rx_buffer_command;
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 15);
    $display("\n\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

  end
endtask
//------------------------------------------------------------------------------

task test_reset_mode;
  begin
    release_rx_buffer_command;
    $display("\n\n");
    read_receive_buffer;
    fifo_info;
    $display("expect: Until now no data was received\n");

    receive_frame(1, 0, 29'h14d60246, 4'h0, 15'h6f54); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h1, 15'h6d38); // mode, rtr, id, length, crc
    receive_frame(1, 0, 29'h14d60246, 4'h2, 15'h053e); // mode, rtr, id, length, crc

    fifo_info;
    read_receive_buffer;
    $display("expect: 3 packets should be received (totally 18 bytes)\n");

    release_rx_buffer_command;
    fifo_info;
    read_receive_buffer;
    $display("expect: 2 packets should be received (totally 13 bytes)\n");


    $display("expect: SW reset performed\n");

    // Switch-on reset mode
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    // Switch-off reset mode
    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});

    fifo_info;
    read_receive_buffer;
    $display("expect: The above read was after the SW reset.\n");

    receive_frame(1, 0, 29'h14d60246, 4'h3, 15'h5262); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    $display("expect: 1 packets should be received (totally 8 bytes). See above.\n");

    // Switch-on reset mode
    $display("expect: SW reset ON\n");
    write_register(8'd0, {7'h0, `CAN_MODE_RESET});

    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc

    fifo_info;
    read_receive_buffer;
    $display("expect: 0 packets should be received because we are in reset. (totally 0 bytes). See above.\n");

/*
    fork
      begin
      receive_frame(1, 0, 29'h14d60246, 4'h4, 15'h4bba); // mode, rtr, id, length, crc
      end
      begin
        // Switch-on reset mode
        write_register(8'd0, {7'h0, `CAN_MODE_RESET});

        // Switch-off reset mode
        write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});


      end

    join
*/




    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h6, 15'h6f40); // mode, rtr, id, length, crc
    fifo_info;
    receive_frame(1, 0, 29'h14d60246, 4'h7, 15'h1730); // mode, rtr, id, length, crc
    fifo_info;
//    read_overrun_info(0, 10);

    release_rx_buffer_command;
    release_rx_buffer_command;
    fifo_info;



    // Switch-off reset mode
    $display("expect: SW reset OFF\n");
    write_register(8'd0, {7'h0, (~`CAN_MODE_RESET)});

    receive_frame(1, 0, 29'h14d60246, 4'h8, 15'h2f7a); // mode, rtr, id, length, crc
    fifo_info;
    read_receive_buffer;
    $display("expect: 1 packets should be received (totally 13 bytes). See above.\n");

    release_rx_buffer_command;
    fifo_info;
    read_receive_buffer;
    $display("expect: 0 packets should be received (totally 0 bytes). See above.\n");
    $display("\n\n");


    fork
      receive_frame(1, 0, 29'h14d60246, 4'h5, 15'h4d7d); // mode, rtr, id, length, crc

      begin
        #8000;
        // Switch-off reset mode
        $display("expect: SW reset ON while receiving a packet\n");
        write_register(8'd0, {7'h0, `CAN_MODE_RESET});
      end
    join


    read_receive_buffer;
    fifo_info;
    $display("expect: 0 packets should be received (totally 0 bytes) because CAN was in reset. See above.\n");

    release_rx_buffer_command;
    read_receive_buffer;
    fifo_info;

  end
endtask   // test_reset_mode
//------------------------------------------------------------------------------

task manual_fd_frame_basic_rcv;
  integer done;
  begin
    // Switch-on reset mode
    write_register(8'd0, {7'h0, (`CAN_MODE_RESET)});

    // Set Acceptance Code and Acceptance Mask registers
    write_register(8'd4, 8'h28); // acceptance code
    write_register(8'd5, 8'hff); // acceptance mask

    repeat (100) @ (posedge clk);

    // Switch-off reset mode
//    write_register(8'd0, {7'h0, ~(`CAN_MODE_RESET)});
    write_register(8'd0, 8'h1e);  // reset_off, all irqs enabled.

    // After exiting the reset mode sending bus free
    repeat (11) send_bit(1);

    write_register(8'd10, 8'h55); // Writing ID[10:3] = 0x55
    write_register(8'd11, 8'h77); // Writing ID[2:0] = 0x3, rtr = 1, length = 7
    write_register(8'd12, 8'h00); // data byte 1
    write_register(8'd13, 8'h00); // data byte 2
    write_register(8'd14, 8'h00); // data byte 3
    write_register(8'd15, 8'h00); // data byte 4
    write_register(8'd16, 8'h00); // data byte 5
    write_register(8'd17, 8'h00); // data byte 6
    write_register(8'd18, 8'h00); // data byte 7
    write_register(8'd19, 8'h00); // data byte 8

    tx_bypassed = 0;    // When this signal is on, tx is not looped back to the rx.


    $monitor("*I (%0t) MON: tx_i = %b, fdf_r = %b", $time, tx_i,
`ifdef CAN_FD_TOLERANT
    can_testbench.i_can_top.i_can_bsp.fdf_r,
    //can_testbench.i_can_top.i_can_bsp.fd_fall_edge_raw
`else
    0, 0, 0
`endif
);
    done = 0;
    fork
    begin
      while (!done) begin
        @(posedge clk);
        if (~tx_i & can_testbench.i_can_top.i_can_bsp.sample_point)
          $display("*I (%0t) tx_i = %b", $time, tx_i);
      end
    end
    begin
        $display("sending FD frame");
        ///*
        send_bit(0);  // SOF
        send_bits(11, 11'b01010101010);    // ID
        send_bit(1);  // RTR
        send_bit(0);  // IDE
        send_bit(1);  // FD
        send_bits(4, 4'b0111);             // DLC
        repeat (10) send_fd_bits(6, 6'b111110);
        // some invalid stuff, does not really matter
        send_bits(15+2, 17'b11000001001011011); // CRC (with 2 stuff bits)
        send_bit(1);  // CRC DELIM
        send_bit(0);  // ACK
        send_bit(1);  // ACK DELIM
        send_bits(7, 7'b1111111); // EOF
        send_bits(3, 7'b111); // INTER
        //*/
//repeat (32) send_bit(1);
        $display("sending OK frame");
        send_bit(0);  // SOF
        send_bits(11, 11'b01010101010);    // ID
        send_bit(1);  // RTR
        send_bit(0);  // IDE
        send_bit(0);  // r0
        send_bits(4, 4'b0111);             // DLC
        send_bits(15+2, 17'b11000001001011011); // CRC (with 2 stuff bits)
        send_bit(1);  // CRC DELIM
        send_bit(0);  // ACK
        send_bit(1);  // ACK DELIM
        send_bits(7, 7'b1111111); // EOF
        send_bits(3, 7'b111); // INTER
        done = 1;
    end
    join



    read_receive_buffer;
    release_rx_buffer_command;

    #1000 read_register(8'd3, tmp_data);
    read_receive_buffer;
    release_rx_buffer_command;
    read_receive_buffer;
  end
endtask   //  manual_fd_frame_basic_rcv
//------------------------------------------------------------------------------

task send_fake_fd_frame;
begin
    $display("sending FD frame");
    //can1_isolate_rx = 1'b0;

    send_bit(0);  // SOF
    send_bits(11, 11'b01010101010);    // ID
    send_bit(1);  // RTR
    send_bit(0);  // IDE
    send_bit(1);  // FD
    send_bits(4, 4'b0111);             // DLC
    repeat (10) send_fd_bits(6, 6'b111110);
    // some invalid stuff, does not really matter
    send_bits(15+2, 17'b11000001001011011); // CRC (with 2 stuff bits)
    send_bit(1);  // CRC DELIM
    send_bit(0);  // ACK
    send_bit(1);  // ACK DELIM
    send_bits(7, 7'b1111111); // EOF
    //can1_isolate_rx = 1'b0;
    send_bits(3, 3'b111); // INTER
end
endtask

task send_and_receive_frame;
  input [1:0] txd;
  input [1:0] rxd;
  reg   [7:0] tmp;
begin
    $display("sending req");
    tx_request_command_impl(txd);
    wait (|(~irqns & txd));
    $display("IRQ from TX caught");
    read_register_impl(txd, 8'd3, tmp); // read IR
    $display("TX IR: 0x%02h", tmp);
    casex (tmp)
    8'hx2: ;
    default: begin
        $display("Unexpected TX irq!");
        $stop;
    end
    endcase
    wait (|(~irqns & rxd));
    read_register_impl(rxd, 8'd3, tmp); // read status
    $display("RX IR: 0x%02h", tmp);
    casex (tmp)
    8'hx1: ;
    default: begin
        $display("Unexpected RX irq!");
        $stop;
    end
    endcase
    read_receive_buffer_impl(rxd);
    release_rx_buffer_command_impl(rxd);
end
endtask

task test_tx_after_fdf;    // CAN IP core sends frames during reception of CAN FD frame
  reg [1:0] txd;
  reg [1:0] rxd;
  integer cnt;
  integer done;
  integer wc;
  begin
    txd = 2'h2;
    rxd = 2'h1;
    write_register_impl(txd, 8'd10, 8'hea); // Writing ID[10:3] = 0xea
    write_register_impl(txd, 8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
    write_register_impl(txd, 8'd12, 8'h56); // data byte 1
    write_register_impl(txd, 8'd13, 8'h78); // data byte 2
    write_register_impl(txd, 8'd14, 8'h9a); // data byte 3
    write_register_impl(txd, 8'd15, 8'hbc); // data byte 4
    write_register_impl(txd, 8'd16, 8'hde); // data byte 5
    write_register_impl(txd, 8'd17, 8'hf0); // data byte 6
    write_register_impl(txd, 8'd18, 8'h0f); // data byte 7
    write_register_impl(txd, 8'd19, 8'hed); // data byte 8

    // Enable irqs (basic mode)
    write_register_impl(2'h3, 8'd0, 8'h1e);

    for (cnt = 0; cnt < 10; cnt = cnt + 1)
      begin
        $display("(%d) CYCLE #%d", $time, cnt);
        done = 0;
        fork
          begin
            while (!done) begin
              @(posedge clk);
              if (i_can_top.i_can_bsp.go_error_frame) begin
                $display("ERROR: error frame detected!");
                $stop;
              end
            end
          end
          begin
            wc = $urandom % 52;
            $display("watiting %d cycles", wc);
            repeat (wc) wait_bit;
            send_and_receive_frame(txd, rxd);
            done = 1;
          end
          begin
            send_fake_fd_frame;
          end
        join
        send_bits(3, 3'b111); // INTER
      end
  end
endtask   // test_tx_after_fdf
//------------------------------------------------------------------------------

task test_tx_after_fdf_err;    // variation
  reg [1:0] txd;
  reg [1:0] rxd;
  integer cnt;
  integer done;
  integer wc;
  begin
    txd = 2'h2;
    rxd = 2'h1;
    write_register_impl(txd, 8'd10, 8'hea); // Writing ID[10:3] = 0xea
    write_register_impl(txd, 8'd11, 8'h28); // Writing ID[2:0] = 0x1, rtr = 0, length = 8
    write_register_impl(txd, 8'd12, 8'h56); // data byte 1
    write_register_impl(txd, 8'd13, 8'h78); // data byte 2
    write_register_impl(txd, 8'd14, 8'h9a); // data byte 3
    write_register_impl(txd, 8'd15, 8'hbc); // data byte 4
    write_register_impl(txd, 8'd16, 8'hde); // data byte 5
    write_register_impl(txd, 8'd17, 8'hf0); // data byte 6
    write_register_impl(txd, 8'd18, 8'h0f); // data byte 7
    write_register_impl(txd, 8'd19, 8'hed); // data byte 8

    // Enable irqs (basic mode)
    write_register_impl(2'h3, 8'd0, 8'h1e);

    for (cnt = 0; cnt < 10; cnt = cnt + 1)
      begin
        $display("(%d) CYCLE #%d", $time, cnt);
        done = 0;
        fork
          begin
            while (!done) begin
              @(posedge clk);
              if (i_can_top.i_can_bsp.go_error_frame) begin
                $display("ERROR: error frame detected!");
                $stop;
              end
            end
          end
          begin
            wc = $urandom % 52;
            $display("watiting %d cycles", wc);
            repeat (wc) wait_bit;
            send_and_receive_frame(txd, rxd);
            done = 1;
          end
          begin
            $display("sending FD frame");
            send_bit(0);  // SOF
            send_bits(11, 11'b01010101010);    // ID
            send_bit(1);  // RTR
            send_bit(0);  // IDE
            send_bit(1);  // FD
            send_bits(4, 4'b0111);             // DLC
            repeat (10) send_fd_bits(6, 6'b111110);
            // send_bits checks for arbitration loss, so this checks the timing lower bound
            if ($urandom % 2)
              begin
                $display("sending Error Frame");
                send_bits(6, 6'h00); // Error Frame
                if ($urandom % 2)
                  send_bits($urandom % 10, 10'h000); // let's extend it a bit ...
                send_bits(8, 8'hFF); // delimiter
                send_bits(3, 3'b111); // INTER
              end
            else
              begin
                $display("sending Overload Frame");
                send_bits(7, 7'h7F); // EOF
                send_bits(6, 6'h00); // Error Frame
                if ($urandom % 2)
                  send_bits($urandom % 10, 10'h000); // let's extend it a bit ...
                send_bits(8, 8'hFF); // delimiter
                send_bits(3, 3'b111); // INTER
              end
          end
        join
        send_bits(3, 3'b111); // INTER
      end
  end
endtask   // test_tx_after_fdf_err
//------------------------------------------------------------------------------


task test_synchronization;
  begin
    // Hard synchronization
    #1 rx=0;
    repeat (2*BRP) @ (posedge clk);
    repeat (8*BRP) @ (posedge clk);
    #1 rx=1;
    repeat (10*BRP) @ (posedge clk);

    // Resynchronization on time
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;
    repeat (10*BRP) @ (posedge clk);

    // Resynchronization late
    repeat (BRP) @ (posedge clk);
    repeat (BRP) @ (posedge clk);
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;

    // Resynchronization early
    repeat (8*BRP) @ (posedge clk);   // two frames too early
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;
    // Resynchronization early
    repeat (11*BRP) @ (posedge clk);   // one frames too late
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
    #1 rx=1;

    repeat (10*BRP) @ (posedge clk);
    #1 rx=0;
    repeat (10*BRP) @ (posedge clk);
  end
endtask
//------------------------------------------------------------------------------
