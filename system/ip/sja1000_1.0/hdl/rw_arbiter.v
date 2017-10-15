module rw_arbiter
(
	input wire  S_AXI_ACLK,
	input wire  S_AXI_ARESETN,
	output reg read_pending,
	output reg read_active,
	output reg write_pending,
	output reg write_active,
	output reg read_active_edge,
	output reg write_active_edge,

	input wire read_finished,
	input wire write_finished,
	
	input wire ready_read_i,
	input wire ready_write_i
);

	wire ready_read_edge;
	wire ready_write_edge;
	reg  [1:0] ready_read_hist;
	reg  [1:0] ready_write_hist;
	assign ready_read_edge = ready_read_hist[0] ^ ready_read_hist[1];
	assign ready_write_edge = ready_write_hist[0] ^ ready_write_hist[1];


    // read/write arbitration
    always @ (posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
    begin
      if (~S_AXI_ARESETN)
      begin
        write_pending <= 1'b0;
        write_active <= 1'b0;
        read_pending <= 1'b0;
        read_active <= 1'b0;
        ready_read_hist <= 2'b00;
        ready_write_hist <= 2'b00;
      end
      else
      begin
        ready_read_hist <= {ready_read_hist[0], ready_read_i};
        ready_write_hist <= {ready_write_hist[0], ready_write_i /*& (S_AXI_WSTRB == 4'b1111)*/};

        /*
        if(S_AXI_AWVALID & S_AXI_WVALID & (S_AXI_WSTRB != 4'b1111))
        begin
          S_AXI_BVALID <= 1;
          S_AXI_BRESP <= ...;
        end
        */

        if (write_active_edge)
          write_active_edge = 0;
        if (read_active_edge)
          read_active_edge = 0;

        if (ready_write_edge)
        begin
          if (read_active & ~read_finished)
            write_pending <= 1;
          else
          begin
            write_active <= 1;
            write_active_edge = 1;
          end
        end

        if (ready_read_edge)
        begin
          if (write_active & ~write_finished)
            read_pending <= 1;
          else
          begin
            read_active <= 1;
            read_active_edge = 1;
          end
        end

        // read finished in previous cycle
        if (read_finished)
        begin
          read_active <= 1'b0;
          if (write_pending)
          begin
            write_active <= 1;
            write_pending <= 0;
          end
        end

        // write finished in previous cycle
        if (write_finished)
        begin
          write_active <= 1'b0;
          if (read_pending)
          begin
            read_active <= 1;
            read_pending <= 0;
          end
        end
      end
    end
endmodule
