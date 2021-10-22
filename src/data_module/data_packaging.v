`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/14 09:08:09
// Design Name: 
// Module Name: data_packaging
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

module data_packaging (
	input 					clk_200m,    			// Clock
	input 					reset,  				// Asynchronous reset active high
	input 					data_valid,				// Indicate the data has been prepared
	input 					trans_start, 			// Transmit start signal
	input 					aligned,				// Data has aligned
	input [15:0] 			input_data,				// One channel data bus
	input [3:0]				board_number, 			// The IP words
	input [3:0] 			chip_number,			// Topmetal's number
	input [31:0] 			header,					// Header
	input [31:0] 			tail,
	output reg				fifo_wren, 				// 
	output reg 				fifo_rden,				//
	output [8:0] 			dp_status,
	output reg [31:0] 		frame_num,
	output reg [31:0] 		out_data				// The output data bus
);

	 localparam 			IDLE 		= 12'b000000000001,
	 						S_HEADER1 	= 12'b000000000010,
	 						W_HEADER1 	= 12'b000000000100,
	 						S_HEADER2	= 12'b000000001000,	
	 						W_HEADER2 	= 12'b000000010000,
	 						WAIT_DATA 	= 12'b000000100000,
	 						S_DATA 		= 12'b000001000000,
	 						C_BUFFER 	= 12'b000010000000,
	 						S_FRAME 	= 12'b000100000000,
	 						S_TAIL 		= 12'b001000000000,
	 						W_TAIL 		= 12'b010000000000,
	 						OVER 		= 12'b100000000000;


	reg [11:0] 				next_state;
	reg [11:0] 				current_state;

	reg [31:0] 				data_buffer;
	reg  					pos_buf1;
	reg 					pos_buf2;  
	reg [15:0] 				pixel_cnt;
	//reg [31:0] 				frame_num;

	reg 					sync_r1;
	reg 					sync_r2;
	reg 					sync_r3;
	wire 					async_align;
	wire 					sync_align;

	assign dp_status = current_state[8:0];


	//------------------------------------------//
	assign async_align = (~aligned) & sync_align;
	assign sync_align = sync_r3;

	always @(posedge aligned or posedge async_align) 
	begin 
		if(async_align) begin
			sync_r1 <= 1'b0;
		end else begin
			sync_r1 <= 1'b1;
		end
	end

	always @(posedge clk_200m) 
	begin 
		sync_r2 <= sync_r1;
		sync_r3 <= sync_r2;	
	end
	//--------------------------------------------//
	// Get the DATA_VALID's posedge
	always @(posedge clk_200m or posedge reset) 
	begin : proc_data_valid
		if(reset) begin
			pos_buf1 <= 0;
			pos_buf2 <= 0;
		end else begin
			pos_buf1 <= data_valid;
			pos_buf2 <= pos_buf1;
		end
	end

	always @(posedge clk_200m or posedge reset) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(current_state or sync_align or pixel_cnt or trans_start or data_buffer) 
	begin : proc_next
		case (current_state)
			// Wait the ADC and software are ready
			IDLE: begin 
				if((~trans_start) & sync_align) begin
					next_state <= S_HEADER1;
				end else begin 
					next_state <= IDLE;
				end
			end
			S_HEADER1: begin 
				//next_state <= W_HEADER1;
				next_state <= S_HEADER2;
			end
			W_HEADER1: begin 
				next_state <= S_HEADER2;
			end
			// generate the package header2 and write header1
			S_HEADER2: begin 
				//next_state <= W_HEADER2;
				next_state <= WAIT_DATA;
			end
			// send package header
			W_HEADER2: begin 
				next_state <= WAIT_DATA;
			end		
			// Wait two pixels' data and convert to 32'bits 
			WAIT_DATA: begin 
				if((data_buffer[31:16] != 16'd0) & (pixel_cnt <= 16'd5184)) begin
					next_state <= S_DATA;
				//end else if(pixel_cnt == 16'd200) begin
				//	next_state <= S_DATA;
				end else begin 
					next_state <= WAIT_DATA;
				end
			end
			// Send the 32'bits data to FIFO
			S_DATA: begin 
				if(pixel_cnt == 16'd5184)
					next_state <= S_FRAME;
				else
					next_state <= C_BUFFER;
			end
			// Clear the data buffer
			C_BUFFER: begin
				next_state <= WAIT_DATA;
			end
			// Generate the frame_num
			S_FRAME: begin 
				next_state <= S_TAIL;   
			end
			// Generate the tail
			S_TAIL: begin 
				//next_state <= W_TAIL;
				next_state <= IDLE;
			end
			W_TAIL: begin 
				next_state <= IDLE;
			end
			default : next_state <= IDLE;
		endcase
	end

	always @(posedge clk_200m) 
	begin : proc_operate
		case (current_state)
			IDLE: begin 
				out_data 	<= 32'd0;
				pixel_cnt 	<= 16'd0;
				if(~trans_start)
					frame_num	<= frame_num;
				else if(trans_start)	
					frame_num	<= 32'd0;
				data_buffer <= 32'd0;
				fifo_wren 	<= 0;
				fifo_rden 	<= 0;
			end
			S_HEADER1: begin 
				out_data 	<= header;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				data_buffer <= 32'd0;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
			end
			W_HEADER1: begin 
				out_data 	<= header;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				data_buffer <= 32'd0;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
			end
			S_HEADER2: begin 
				// {Identification bit(16'bits),board number(8'bits), chip number(8'bits)}
				out_data 	<= {16'h55AA,{12'd0,chip_number}};
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				data_buffer <= 32'd0;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
			end
			W_HEADER2: begin 
				out_data 	<= out_data;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				data_buffer <= 32'd0;
				fifo_wren 	<= 1;
				fifo_rden 	<= 1;
			end
			WAIT_DATA: begin 
				out_data 	<= 32'd0;
				//pixel_cnt 	<= pixel_cnt;
				frame_num	<= frame_num;
				fifo_wren 	<= 0; 
				if(pos_buf1 & (~pos_buf2)) begin 
					data_buffer[31:16] <= data_buffer[15:0];
					data_buffer[15:0]  <= input_data;
					pixel_cnt 	<= pixel_cnt + 1;
				end
				fifo_rden 	<= 1;
			end
			S_DATA: begin 
				out_data 	<= data_buffer;
				//pixel_cnt 	<= pixel_cnt + 1;
				pixel_cnt 	<= pixel_cnt;
				data_buffer <= data_buffer;
				fifo_wren 	<= 1;
				fifo_rden 	<= 1;
				frame_num	<= frame_num;
				if(pixel_cnt == 16'd5184)
					frame_num	<= frame_num + 1;
			end
			C_BUFFER: begin 
				out_data 	<= 0;
				pixel_cnt 	<= pixel_cnt;
				fifo_wren 	<= 0;
				fifo_rden 	<= 0;
				data_buffer <= 0;
				frame_num	<= frame_num;
			end
			S_FRAME: begin 
				out_data 	<= frame_num;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
				data_buffer <= 32'd0;
			end
			S_TAIL: begin 
				out_data 	<= tail;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
				data_buffer <= 32'd0;
			end
			W_TAIL: begin 
				out_data 	<= tail;
				pixel_cnt 	<= 16'd0;
				frame_num	<= frame_num;
				fifo_wren 	<= 1;
				fifo_rden 	<= 0;
				data_buffer <= 32'd0;
			end
			default : begin 
				out_data 	<= 32'd0;
				pixel_cnt 	<= 16'd0;
				frame_num	<= 0;
				fifo_wren 	<= 0;
				fifo_rden 	<= 0;
				data_buffer <= 32'd0;
			end
		endcase
	end

endmodule