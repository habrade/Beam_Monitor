`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/16 20:16:06
// Design Name: 
// Module Name: topmetal2_wrap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Topmetal-2 project's top wrapper 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module data_delay2 (
	input wire 				clk_ref,    	// Clock
	input wire 				reset,  		// Asynchronous reset active low
	input wire [13:0] 		data_pattern, 	// From data module
	input wire 				fco_aligned,
	input wire 				ad_test_mode, 	// Indicates the ADC is test mode
	input wire 				soft_start,
	output reg				idelay_ld, 	 	// For IDELAYE2's LD port, when "1", the IDELAYE2 will load the taps value
	output reg 				idelay_ce,
	output reg 				idelay_inc,
	output reg 				dat_bitslip,
	output reg [4:0] 		cnt_value, 		// Taps value for IDELAYE2
	output reg 				dat_aligned,		// Indicates the data is valid
	output wire [8:0] 		delay_fsm			
);
	localparam 				DLY_MLT_CYCLE = 15;
	localparam 				IDLE 		= 10'b0000000001,
							INCRE 		= 10'b0000000010, 	// taps increase
							DLY_LD 		= 10'b0000000100,
							BIT_SLIP	= 10'b0000001000,
							WAIT2 		= 10'b0000010000,
							WAIT 		= 10'b0000100000, 	// wait increase
							JUDGE		= 10'b0001000000,
							INC_DON 	= 10'b0010000000, 	// This state will increase the taps with 2, at last
							DON_LD 		= 10'b0100000000, 	// This state the last time to load the taps value for IDELAYE2
							OVER 		= 10'b1000000000;

	reg [9:0] 			current_state;
	reg [9:0] 			next_state;
	reg 				fco_align_buf;
	reg [7:0]			dly_cycles; 
	reg [15:0] 			judge_cnt; 		// After 15 clock cycles, review the data pattern is valid 

	assign delay_fsm = current_state;

	always @(posedge clk_ref or posedge reset) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(current_state or fco_aligned or dly_cycles 
				or judge_cnt or ad_test_mode or cnt_value or soft_start) 
	begin : proc_next
		case (current_state)
			IDLE: begin 
				if(fco_aligned & ad_test_mode & (~soft_start))
					next_state <= BIT_SLIP;
				else 
					next_state <= IDLE;
			end
			INCRE: begin
				if(data_pattern == 14'h2867) 
					next_state <= WAIT;
				else 
					next_state <= DLY_LD; 
				
			end
			DLY_LD: begin 
				if(cnt_value == 5'h00)
					next_state <= WAIT2;
				else
					next_state <= WAIT;
			end
			BIT_SLIP: begin 
				next_state <= WAIT;
			end
			WAIT2: begin 
				if(dly_cycles == 8'd1)
					next_state <= BIT_SLIP;
				else 
					next_state <= WAIT2;
			end
			WAIT: begin 
				if(dly_cycles == 8'd1)
					next_state <= JUDGE;
				else 
					next_state <= WAIT;
			end
			JUDGE: begin 
				if((data_pattern == 14'h2867) & (judge_cnt == 16'd100))
					next_state <= INC_DON;
				else if((data_pattern == 14'h2867) & (judge_cnt != 16'd100))
					next_state <= JUDGE;
				else if(data_pattern != 14'h2867)
					next_state <= INCRE;
			end
			INC_DON: begin 
				next_state <= DON_LD;
			end
			DON_LD: begin
				next_state <= OVER; 
			end
			OVER: begin 
				next_state <= OVER;
			end
			default: begin 
				next_state <= IDLE;
			end

		endcase
	end

	always @(negedge clk_ref) 
	begin : proc_operate
		case (current_state)
			IDLE: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= 1;
				dat_bitslip <= 0;
			end
			INCRE: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value + 1;
				dat_bitslip <= 0;
			end
			DLY_LD: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 1;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			BIT_SLIP: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= 1;
				dat_bitslip <= 1;
			end
			WAIT2: begin 
				dly_cycles 	<= dly_cycles - 1;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			WAIT: begin 
				dly_cycles 	<= dly_cycles - 1;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= judge_cnt;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			JUDGE: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= judge_cnt + 1;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			INC_DON:begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value + 1;
				dat_bitslip <= 0;
			end
			DON_LD:begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 1;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			OVER: begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 1;
				judge_cnt 	<= 0;
				cnt_value 	<= cnt_value;
				dat_bitslip <= 0;
			end
			default : begin 
				dly_cycles 	<= DLY_MLT_CYCLE;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				dat_bitslip <= 0;
			end
		endcase
	end

endmodule