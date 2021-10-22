`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/29 09:13:15
// Design Name: 
// Module Name: adc9252_wrap
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


module adc9252_spi(
	input wire			clk_adc,
	input wire			reset,
	input wire 			start,
	input wire 			data_aligned,
	input wire          pulse_ad,
	//input [15:0]		adc_data,
	output wire 		test_cfg_done,
	output wire 		sclk_adc,
	output wire 		sdio_adc,
	output wire 		csb_adc,
	output wire 		busy_9252,
	output wire [4:0] 	state_9,
	output wire 		spi_done
	);


	wire 				clk_25m;
	wire  [31:0]        adc_data_32;
	wire 				start_9252;

	config_9252 config_9252
	(
		.clk				(clk_adc),	
		.reset				(reset),
		.data_aligned 		(data_aligned),
		.busy_9252			(busy_9252),

		.adc_data			(adc_data_32),
		.state_9 			(state_9),
		.test_cfg_done 		(test_cfg_done),
		.start				(start_9252),
		.spi_done 			(spi_done)
	);

	adc_data_shift ad9252_data_inst
	(
		.clk 				(clk_adc),
		.reset				(reset),
		.start 				(start_9252),
		.adc_data 			(adc_data_32),

		.sclk_adc 			(sclk_adc),
		.csb_adc 			(csb_adc),
		.sdio_adc	 		(sdio_adc),
		.over 				(),
		.busy				(busy_9252)
	);
endmodule
