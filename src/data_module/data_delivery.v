`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/14 09:08:09
// Design Name: 
// Module Name: data_delivery
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

module data_delivery #
(
	parameter 				ADC_CHANEL = 4
	)
	(
	input 					clk_200m,    			// Clock
	input 					reset, 		 			// Asynchronous reset active low
//	input 					trans_start, 			// Transmit start,come from PC
	input [ADC_CHANEL*32-1:0] 	data_in, // data from FIFO
	input 		 			fifo_empty, 			// Prev FIFO empty signal
	output reg [3:0]		fifo_rden, 				// Prev FIFO read enable
	output reg 				fifo_wren, 				// Next FIFO write enable
	output reg [31:0] 		data_out 				// Next FIFO's DATA
);
	
	localparam 				IDLE 		= 1,
							DATA_SEL 	= 2,
							GET_DATA 	= 3,
							OVER 		= 4;

	reg [7:0] 				state;	
	reg [1:0]	 			channel_sel;
	reg [15:0] 				rden_buf;

	always @(posedge clk_200m or posedge reset) begin : proc_state
		if(reset) begin
			state 		<= IDLE;
			data_out	<= 32'd0;
			fifo_rden 	<= 4'd0;
			channel_sel <= 2'd0;
			fifo_wren 	<= 0;
			rden_buf 	<= 0;
		end else begin
			case (state)
				// Wait the prev FIFO is empty 
				IDLE: begin 
					if(fifo_empty == 0)begin 
						state 		<= GET_DATA;
						fifo_rden	<= 4'b0001;
					end else begin 
						state 		<= IDLE;
						fifo_rden	<= 4'b0000;
					end 
					data_out 	<= 32'd0;
					channel_sel <= 0;
					fifo_wren 	<= 0;
					rden_buf 	<= 0;
				end
				// Select the data from prev FIFOs, and generate read enable signal
				DATA_SEL: begin 
					state 		<= GET_DATA;
					//fifo_rden 	<= fifo_rden << 1;
					fifo_rden 	<= rden_buf;
					rden_buf 	<= rden_buf;
					data_out 	<= data_out;
					channel_sel <= channel_sel + 1;
					//if(data_in[511:480] != 32'd0)
					fifo_wren 	<= 0;
				end
				// Get one FIFO's data in prev FIFOs, and write it to the next FIFO
				GET_DATA: begin 
					fifo_rden 	<= 0;
					data_out 	<= data_in[((channel_sel + 1)*32 -1) -:32];
					channel_sel <= channel_sel;
					rden_buf 	<= fifo_rden << 1;
					//if(data_in[511:480] != 32'd0)
					fifo_wren 	<= 1;
					if(channel_sel == 2'b11) begin
						state 	<= IDLE;
					end else begin 
						state 	<= DATA_SEL;
					end
				end
				default : begin 
					state 		<= IDLE;
					fifo_rden 	<= 0;
					data_out 	<= 32'd0;
					channel_sel <= 0;
				end
			endcase
		end
	end

endmodule