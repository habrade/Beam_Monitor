`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/7/1 09:06:09
// Design Name: 
// Module Name: bitslip_wren
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module bitslip_wren (
	input wire				ad_dco_fc,    			// Clock
	input wire				reset,  // Asynchronous reset active high
	input wire [13:0] 		fco_pattern,
	input wire 				data_aligned,
	input wire 				data_fifo_full,
	input wire 				spi_done,
	input wire 				clk_en,
	output wire 			bit_slip,
	output reg 				fco_aligned,
	output wire 			data_fifo_wren,
	output wire [3:0] 		state_wren
);
	localparam 				IDLE	= 4'b0001,
							WAIT 	= 4'b0010,
							WORK 	= 4'b0100,
							OVER	= 4'b1000;

	reg 					bit_slip_reg;
	reg [2:0] 				detect_wait;
	reg 					fifo_wr_en;
	reg [2:0]				delay_cnt;

	reg [3:0] 				current_state;
	reg [3:0] 				next_state;

	wire 					restart;
	wire 					sm_continue;

	
	always @(posedge ad_dco_fc or posedge reset) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(current_state or delay_cnt or restart or data_fifo_full or fco_pattern) 
	begin : proc_next
		case (current_state)
			IDLE:
			begin 
				if(fco_pattern == 14'h3F80)
					next_state <= WAIT;
				else
					next_state <= IDLE;
			end
				
			WAIT:
			begin 
				if(delay_cnt == 3'd4)
					next_state <= WORK;
				else
					next_state <= WAIT;
			end
			WORK:
			begin 
				if(restart)
					next_state <= IDLE;
				else if(data_fifo_full)
					next_state <= OVER;
				else 
					next_state <= WORK;
			end
			OVER:
				if(restart)
					next_state <= IDLE;
				else if(~data_fifo_full)
					next_state <= WORK;
				else
					next_state <= OVER;		
			default : 
				next_state <= IDLE;
		endcase
	end

	always @(posedge ad_dco_fc) 
	begin : proc_state_operate
		case (current_state)
			IDLE:
			begin
				fifo_wr_en 	<= 0;
				delay_cnt 	<= 0;
			end
			WAIT:
			begin 
				fifo_wr_en 	<= 0;
				delay_cnt 	<= delay_cnt + 1;
			end
			WORK:
			begin 
				fifo_wr_en 	<= 1;
				delay_cnt 	<= 0;
			end
			OVER:
			begin 
				fifo_wr_en 	<= 0;
				delay_cnt 	<= 0;
			end
		
			default : 
			begin 
				fifo_wr_en 	<= 0;
				delay_cnt 	<= 0;
			end
		endcase
	end

	//The FCO alignment is detected every three ad_dco_fc clock cycles.
   always @(posedge ad_dco_fc or posedge reset) 
   begin : proc_bit_slip
	if(reset) begin
		bit_slip_reg <= 0;
		detect_wait  <= 0;
	end else if(clk_en & (detect_wait == 3'b100) & (fco_pattern != 14'h3F80)) begin
		bit_slip_reg <= 1;
		detect_wait  <= 0;
	end else if(clk_en) begin 
		bit_slip_reg <= 0;
		detect_wait  <= detect_wait + 1;
	end
   end

   always @(posedge ad_dco_fc or posedge reset) 
   begin : proc_fco_aligned
   	if(reset) begin
   		fco_aligned <= 0;
   	end else if(fco_pattern == 14'h3F80) begin
   		fco_aligned <= 1;
   	end else begin 
   		fco_aligned <= 0;
   	end
   end

   assign bit_slip 			= bit_slip_reg;
   assign data_fifo_wren 	= fifo_wr_en;
   assign restart 			= (fco_pattern != 14'h3F80) ? 1 : 0;
   assign state_wren 		= current_state;
endmodule