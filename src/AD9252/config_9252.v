`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/15 20:49:10
// Design Name: 
// Module Name: config_9252
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


module config_9252(
    input 				clk,
	input 				reset,
	input 				busy_9252,
	input 				data_aligned,
	output reg [31:0] 	adc_data,
	output reg 			start,
	output reg 			test_cfg_done,
	output wire [4:0] 	state_9,
	output reg 			spi_done
	);

	localparam [23:0]	DELAY_1S	= 24'h400;
	localparam [31:0] 	TEST_MODE 	= 32'h000D0C0C;
	localparam [31:0] 	WORK_MODE 	= 32'h000D0000;

	localparam 			IDLE 		= 1,
						DELAY_A		= 2,
						CFG_TEST	= 3,
						DELAY_B	 	= 4,
						UPDATE_T 	= 5,
						DELAY_C 	= 6,
						CFG_WORK 	= 7,
						DELAY_D 	= 8,
						UPDATE_W 	= 9,
						DONE 		= 10;

	(*mark_debug = "true"*)  reg [4:0] 			current_state;
	(*mark_debug = "true"*)  reg [4:0] 			next_state;
	reg [23:0] 			delay_cnt;
	(*mark_debug = "true"*)  reg 				cfg_testdone;
	(*mark_debug = "true"*)  reg 				cfg_workdone;
	assign state_9 = current_state;
	always @(posedge clk) 
	begin : proc_current
		if(reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	always @(current_state or busy_9252 or delay_cnt or data_aligned) 
	begin : proc_next
		case (current_state)
			IDLE :
			begin 
				if(~busy_9252)
					next_state <= DELAY_A;
				else
					next_state <= IDLE;
			end
			DELAY_A :
			begin 
				if(delay_cnt == 24'd1)
					next_state <= CFG_TEST;
				else 
					next_state <= DELAY_A;
			end
			CFG_TEST :
			begin 
				next_state <= DELAY_B;
			end
			DELAY_B:
			begin 
				if(delay_cnt == 24'd1)
					next_state <= UPDATE_T;
				else 
					next_state <= DELAY_B;
			end
			UPDATE_T:
			begin 
				next_state <= DELAY_C;
			end
			DELAY_C:
			begin 
				if(data_aligned)
					next_state <= CFG_WORK;
				else 
					next_state <= DELAY_C;
			end
			CFG_WORK:
			begin 
				next_state <= DELAY_D;
			end
			DELAY_D:
			begin 
				if(delay_cnt == 24'd1)
					next_state <= UPDATE_W;
				else 
					next_state <= DELAY_D;
			end
			UPDATE_W :
			begin 
				next_state <= DONE;
			end
			DONE :
			begin 
				next_state <= DONE;
			end
			default : 
			begin 
				next_state <= IDLE;
			end
		endcase
	end

	always @(posedge clk) 
	begin : proc_
		case (current_state)
			IDLE :
			begin 
				adc_data		<= 32'h00000000;
				start			<= 1'b0;
				delay_cnt 		<= DELAY_1S;
				test_cfg_done 	<= 0;
				spi_done 		<= 1'b0;
			end
			DELAY_A :
			begin 
			//	adc_data	<= 32'h00000000;
				start			<= 1'b0;
				delay_cnt		<= delay_cnt - 1'b1;
				test_cfg_done 	<= 0;
				spi_done 		<= 1'b0;
			end
			CFG_TEST :
			begin 
				adc_data		<= TEST_MODE;
				start			<= 1'b1;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= 0;
				spi_done 		<= 1'b0;
			end
			DELAY_B:
			begin 
				start			<= 1'b0;
				delay_cnt		<= delay_cnt - 1'b1;
				test_cfg_done 	<= 0;
				spi_done 		<= 1'b0;
			end
			UPDATE_T:
			begin 
				adc_data		<= 32'h00FF0101;
				start			<= 1'b1;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= 0;
				spi_done 		<= 1'b0;
			end
			DELAY_C:
			begin 
				start			<= 1'b0;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= 1;
				spi_done 		<= 1'b0;
			end
			CFG_WORK :
			begin 
				adc_data		<= WORK_MODE;
				start			<= 1'b1;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= test_cfg_done;
				spi_done 		<= 1'b0;
			end
			DELAY_D:
			begin 
				start			<= 1'b0;
				delay_cnt		<= delay_cnt - 1;
				test_cfg_done 	<= test_cfg_done;
				spi_done 		<= 1'b0;
			end
			UPDATE_W :
			begin 
				adc_data		<= 32'h00FF0101;
				start			<= 1'b1;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= test_cfg_done;
				spi_done 		<= 1'b0;
			end
			DONE :
			begin 
				adc_data		<= 32'h00FF0101;
				start			<= 1'b0;
				delay_cnt		<= DELAY_1S;
				test_cfg_done 	<= test_cfg_done;
				spi_done 		<= 1'b1;
			end
			default : 
			begin 
				adc_data		<= 32'h00000000;
				start			<= 1'b0;
				delay_cnt		<= DELAY_1S;
			end
		endcase
	end
endmodule
