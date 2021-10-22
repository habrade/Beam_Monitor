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

module data_delay (
	input wire 				clk_ref,    // Clock
	input wire 				reset,  // Asynchronous reset active low
	input wire [13:0] 		data_pattern,
	input wire 				fco_aligned,
	input wire 				ad_test_done,
	output reg				idelay_ld,
	output reg 				idelay_ce,
	output reg 				idelay_inc,
	output reg 				dat_aligned
);
	localparam 				DLY_8CY = 8;
	localparam 				IDLE 	= 6'b000001,
							INCRE 	= 6'b000010, 	// taps increase
							DECRE 	= 6'b000100,	// taps decrease
							WAIT_I 	= 6'b001000, 	// wait increase
							WAIT_D 	= 6'b010000,	// wait decrease
							OVER 	= 6'b100000;

	reg [5:0] 			current_state;
	reg [5:0] 			next_state;
	reg 				fco_align_buf;
	reg [3:0]			delay_8cyc;
	reg [3:0] 			count_i;
	reg [4:0] 			count_d;

	always @(posedge clk_ref or posedge reset) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
			fco_align_buf <= 0;
		end else begin
			current_state <= next_state;
			fco_align_buf <= fco_aligned;
		end
	end

	always @(current_state or fco_aligned or ad_test_done or data_pattern 
				or delay_8cyc or count_i or count_d) 
	begin : proc_next
		case (current_state)
			IDLE: begin 
				if(fco_aligned & ad_test_done)
					next_state <= INCRE;
				else 
					next_state <= IDLE;
			end
			INCRE: begin 
				next_state <= WAIT_I;
			end
			DECRE: begin 
				next_state <= WAIT_D;
			end
			WAIT_I: begin 
				if(data_pattern == 14'h2867)
					next_state <= OVER;
				else if((data_pattern != 14'h2867) & count_i == 4'd15)
					next_state <= DECRE;
				else if(delay_8cyc == 4'd1)
					next_state <= INCRE;
				else 
					next_state <= WAIT_I;
			end
			WAIT_D: begin 
				if(data_pattern == 14'h2867)
					next_state <= OVER;
				else if((data_pattern != 14'h2867) & count_d == 5'd31)
					next_state <= IDLE;
				else if(delay_8cyc == 4'd1)
					next_state <= DECRE;
				else 
					next_state <= WAIT_D;
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
				delay_8cyc 	<= DLY_8CY;
				idelay_ld	<= 1;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				count_i 	<= 0;
				count_d 	<= 0;
			end
			INCRE: begin 
				delay_8cyc 	<= DLY_8CY;
				idelay_ld	<= 0;
				idelay_ce	<= 1;
				idelay_inc	<= 1;
				dat_aligned	<= 0;
				count_i 	<= count_i + 1;
				count_d 	<= 0;
			end
			DECRE: begin 
				delay_8cyc 	<= DLY_8CY;
				idelay_ld	<= 0;
				idelay_ce	<= 1;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				count_i 	<= 0;
				count_d 	<= count_d + 1;
			end
			WAIT_I: begin 
				delay_8cyc 	<= delay_8cyc - 1;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				count_i 	<= count_i;
				count_d 	<= count_d;
			end
			WAIT_D: begin 
				delay_8cyc 	<= delay_8cyc - 1;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				count_i 	<= count_i;
				count_d 	<= count_d;
			end
			OVER: begin 
				delay_8cyc 	<= DLY_8CY;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 1;
				count_i 	<= 0;
				count_d 	<= 0;
			end
			default : begin 
				delay_8cyc 	<= DLY_8CY;
				idelay_ld	<= 0;
				idelay_ce	<= 0;
				idelay_inc	<= 0;
				dat_aligned	<= 0;
				count_i 	<= 0;
				count_d 	<= 0;
			end
		endcase
	end

endmodule