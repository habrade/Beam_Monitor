`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/26 17:22:11
// Design Name: 
// Module Name: adc_control
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


module adc_data_shift(
    clk,
    reset,
    start,
    adc_data,
    sclk_adc,
    csb_adc,
    sdio_adc,
    over,
    busy
    );

	input 					clk;
    input 					reset;
    input 					start;
    input [31:0]			adc_data;
    output reg 				sdio_adc;
    output reg				sclk_adc;
    output reg				csb_adc;
    output reg 				over;
    output reg				busy;
	
	reg [31:0]				data_buf;
	reg [4:0]				cnt;
	reg [3:0] 				current_state;
	reg [3:0]				next_state;

	localparam 		INIT 		= 4'b0000,
					GET_DATA	= 4'b0001,
					CON_P2S 	= 4'b0010,
					LEFT_SHIFT	= 4'b0100,
					DONE 		= 4'b1000;

	always @(posedge clk or posedge reset) 
	begin : proc_state_machine
		if(reset) begin
			current_state 	<= INIT;
		end else begin
			current_state <= next_state;
		end
	end
	// State machine first section, state machine switching.
	always @(cnt or current_state or start) 
	begin : proc_state_change
		case (current_state)
			INIT : 
			begin 
			 	if(start) 
			 		next_state <= GET_DATA; 
			 	else 
			 		next_state <= INIT; 
		 	end
		 	GET_DATA :
		 	begin 
		 		next_state <= CON_P2S;
		 	end	
		 	CON_P2S :
		 	begin 
		 		if(cnt >= 5'h18)
		 			next_state <= DONE;
		 		else
		 			next_state <= LEFT_SHIFT;
		 	end
		 	LEFT_SHIFT :
		 	begin 
		 		next_state <= CON_P2S;
		 	end
		 	DONE :
		 	begin 
		 		next_state <= INIT;
		 	end
		 	default : 
		 	begin 
		 		next_state <= INIT;
		 	end	
		endcase
	end

	// The second section of the state machine, 
	// the specific functions of the state machine.
	always @(posedge clk) 
	begin : proc_state_operate
		case (current_state)
			INIT : 			// Initializing those interface of this module
			begin 
			 	cnt 		<= 1'b0;
			 	data_buf	<= 32'h0000;
			 	sclk_adc	<= 1'b1;
			 	sdio_adc	<= 1'b0;
			 	csb_adc		<= 1'b1;
			 	busy 		<= 1'b0;
			 	over 		<= 1'b0; 
		 	end
		 	GET_DATA :		// Get the config data into data_buf
		 	begin 
		 		cnt 		<= 1'b0;
			 	data_buf	<= adc_data;
			 	sclk_adc	<= 1'b1;
			 	sdio_adc	<= 1'b0;
			 	csb_adc		<= 1'b0;
			 	busy 		<= 1'b1; 
			 	over 		<= 1'b0;
		 	end	
		 	CON_P2S :		// Conver the parallel bus to serial bus
		 	begin 
		 		cnt 		<= cnt + 1'b1;
			 	data_buf	<= data_buf;
			 	sclk_adc	<= 1'b0;
			 	sdio_adc	<= data_buf[31];
			 	csb_adc		<= 1'b0;
			 	busy 		<= 1'b1; 
			 	over 		<= 1'b0;
		 	end
		 	LEFT_SHIFT :	// Shift-left the parallel bus
		 	begin 
		 		cnt 		<= cnt;
			 	data_buf	<= data_buf << 1;
			 	sclk_adc	<= 1'b1;
			 	sdio_adc	<= sdio_adc;
			 	csb_adc		<= 1'b0;
			 	busy 		<= 1'b1; 
			 	over 		<= 1'b0;
		 	end
		 	DONE :	 		// Transfer and transmmit are completed
		 	begin 
		 		cnt 		<= 1'b0;
			 	data_buf	<= 32'h0000;
			 	sclk_adc	<= 1'b0;
			 	sdio_adc	<= 1'b0;
			 	csb_adc		<= 1'b1;
			 	busy 		<= 1'b0;
			 	over 		<= 1'b1;
		 	end
		 	default : 
		 	begin 
		 		cnt 		<= 1'b0;
			 	data_buf	<= 32'h0000;
			 	sclk_adc	<= 1'b0;
			 	sdio_adc	<= 1'b0;
			 	csb_adc		<= 1'b1;
			 	busy 		<= 1'b0;
		 	end	
		endcase
	end
endmodule
