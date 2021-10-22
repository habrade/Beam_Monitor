`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/09/18 14:00:21
// Design Name: 
// Module Name: data_compression
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

module data_compress
	(
	input wire						ad_fco_clk,    		// ADC frame clock
	input wire						reset,  			// Asynchronous reset active high
	input wire						marker_a, 			// Indicate the first pixel
	input wire 						data_aligned,		//
	input wire [13:0] 				adc_data, 			// One channel data of ADC
	output wire 					data_valid,			// Indicate the data is validity
	output wire [13:0]				compressed_data		// Have compressed
);

	localparam 			IDLE 			= 4'b0001,
						DATA_SUM 		= 4'b0010,
						DATA_DIV 		= 4'b0100,
						DLY_11CYCLE 	= 4'b1000;


	reg  [4:0] 			next_state;
	reg  [4:0] 			current_state;					

	reg  [19:0] 		data_sum;
	reg  [13:0] 		data_div;
	reg  [3:0] 			data_cnt;
	reg  				data_valid_buf;
	reg  [15:0]			pixel_cnt; // cali the pixel number
	
	reg  [3:0] 			delay_11cycle;

	always @(posedge ad_fco_clk or posedge reset) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(current_state or data_cnt or delay_11cycle or marker_a or data_aligned) 
	begin : proc_next
		case (current_state)
			IDLE: 
			begin 
				if(marker_a & data_aligned) begin
					next_state <= DATA_SUM;
				end else begin 
					next_state <= IDLE;
				end
			end
			//----------------------------------------------------------//20ns
			//----------------------------------------------------------//
			// DATA_SUM and DATA_DIV takes (320 + 40) = 380ns 			//
			//----------------------------------------------------------//
			DATA_SUM: 
			begin 
				if(data_cnt == 4'd7) begin
					next_state <= DATA_DIV;
				end else begin 
					next_state <= DATA_SUM;
				end
			end
			DATA_DIV: 
			begin
				next_state <= DLY_11CYCLE;
			end
			//-------------------------------------------------------// 380ns
			//---------------------------------------------------------//
			DLY_11CYCLE:
			begin 
				if(delay_11cycle == 4'd10 & pixel_cnt < 16'd5184) begin 
					next_state <= DATA_SUM;
				end else if(pixel_cnt == 16'd5184) begin
					next_state <= IDLE;
				end else begin 
					next_state <= DLY_11CYCLE;
				end
			end
			//---------------------------------------------------------// 420ns
			default : 
			begin 
				next_state <= IDLE;
			end
		endcase
	end

	always @(posedge ad_fco_clk) 
	begin : proc_state_process
		case (current_state)
			IDLE: 
			begin 
				data_div		<= 14'd0;
				data_sum 		<= 20'd0;
				data_cnt 		<= 4'd0;
				delay_11cycle 	<= 6'd0;
				data_valid_buf 	<= 1'b0;
				pixel_cnt 		<= 16'd0;
			end
			DATA_SUM: 
			begin 
				data_div		<= 14'd0;
				data_sum 		<= data_sum + adc_data;
				data_cnt 		<= data_cnt + 1;
				delay_11cycle 	<= 6'd0;
				data_valid_buf 	<= 1'b0;
				pixel_cnt 		<= pixel_cnt;
			end
			DATA_DIV: 
			begin
				data_div 		<= data_sum >> 3; // Devide 8
				data_sum 		<= data_sum;
				data_cnt 		<= 4'd0;
				delay_11cycle 	<= 6'd0;
				data_valid_buf 	<= 1'b1;
				pixel_cnt 		<= pixel_cnt + 1;
			end
			DLY_11CYCLE:
			begin 
				data_div		<= data_div;
				data_sum 		<= 20'd0;
				data_cnt 		<= 4'd0;
				delay_11cycle 	<= delay_11cycle + 1;
				data_valid_buf 	<= 1'b0;
				pixel_cnt 		<= pixel_cnt;
			end
			default : 
			begin 
				data_div		<= 14'd0;
				data_sum 		<= 20'd0;
				data_cnt 		<= 4'd0;
				delay_11cycle 	<= 6'd0;
				data_valid_buf  <= 1'b0;
			end
		endcase
	end

	assign compressed_data  = data_div;
	assign data_valid 		= data_valid_buf;
endmodule