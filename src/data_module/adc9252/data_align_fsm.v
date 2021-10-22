`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/16 20:16:06
// Design Name: 
// Module Name: data_align_fsm
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

module data_align_fsm (
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
	output wire [9:0] 		delay_fsm			
);
	localparam 				DLY_MLT_CYCLE = 15;
	localparam 				IDLE 		= 14'b00000000000001,
							INCRE 		= 14'b00000000000010, 	// taps increase
							DLY_LD 		= 14'b00000000000100,
							BIT_SLIP	= 14'b00000000001000,
							WAIT2 		= 14'b00000000010000,
							WAIT 		= 14'b00000000100000, 	// wait increase
							JUDGE		= 14'b00000001000000,
							INC_6T 		= 14'b00000010000000, 	// This state will increase the taps with 2, at last
							DLY_LD2 	= 14'b00000100000000,
							JUDGE2 		= 14'b00001000000000,
							CUMULATE 	= 14'b00010000000000, 	// Add two Tap values
							REVISE 		= 14'b00100000000000,
							DONE_LD 	= 14'b01000000000000, 	// This state the last time to load the taps value for IDELAYE2
							OVER 		= 14'b10000000000000;
	
	reg [13:0] 			current_state;
	reg [13:0] 			next_state;
	
	reg [7:0]			dly_cycles; 
	reg [19:0] 			judge_cnt; 		// After 15 clock cycles, review the data pattern is valid 
	reg [5:0] 			cntvalue_buf;

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
				if((data_pattern == 14'h2867) & (judge_cnt == 20'hFFFFF))
					next_state <= INC_6T;
				else if((data_pattern == 14'h2867) & (judge_cnt != 20'hFFFFF))
					next_state <= JUDGE;
				else if(data_pattern != 14'h2867)
					next_state <= INCRE;
			end
			INC_6T: begin 
				next_state <= DLY_LD2;
			end
			DLY_LD2: begin
				next_state <= JUDGE2; 
			end
			JUDGE2: begin 
				if((data_pattern == 14'h2867) & (judge_cnt == 20'hFFFFF))
					next_state <= CUMULATE;
				else if((data_pattern == 14'h2867) & (judge_cnt != 20'hFFFFF))
					next_state <= JUDGE2;
				else if(data_pattern != 14'h2867)
					next_state <= BIT_SLIP;
			end
			CUMULATE: begin 
				next_state <= REVISE;
			end
			REVISE: begin 
				next_state <= DONE_LD;
			end
			DONE_LD: begin 
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
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= 1;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			INCRE: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value + 1;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			DLY_LD: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 1;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			BIT_SLIP: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= 1;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 1;
			end
			WAIT2: begin 
				dly_cycles 		<= dly_cycles - 1;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			WAIT: begin 
				dly_cycles 		<= dly_cycles - 1;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= judge_cnt;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			JUDGE: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= judge_cnt + 1;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= 0;
				dat_bitslip 	<= 0;
			end
			INC_6T:begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value + 3;
				cntvalue_buf	<= cnt_value;
				dat_bitslip 	<= 0;
			end
			DLY_LD2:begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 1;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= cntvalue_buf;
				dat_bitslip 	<= 0;
			end
			JUDGE2: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= judge_cnt + 1;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= cntvalue_buf;
				dat_bitslip 	<= 0;
			end
			CUMULATE: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= cntvalue_buf + cnt_value;
				dat_bitslip 	<= 0;
			end
			REVISE: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				//cnt_value 		<= cnt_value;
				cnt_value 		<= cntvalue_buf >> 1;
				cntvalue_buf	<= cntvalue_buf;
				dat_bitslip 	<= 0;
			end
			DONE_LD: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 1;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= cntvalue_buf;
				dat_bitslip 	<= 0;
			end
			OVER: begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 1;
				judge_cnt 		<= 0;
				cnt_value 		<= cnt_value;
				cntvalue_buf	<= cntvalue_buf;
				dat_bitslip 	<= 0;
			end
			default : begin 
				dly_cycles 		<= DLY_MLT_CYCLE;
				idelay_ld		<= 0;
				idelay_ce		<= 0;
				idelay_inc		<= 0;
				dat_aligned		<= 0;
				dat_bitslip 	<= 0;
			end
		endcase
	end

endmodule