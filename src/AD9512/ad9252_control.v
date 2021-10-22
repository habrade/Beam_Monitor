`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/21 09:06:09
// Design Name: 
// Module Name: da_ad_control
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


module ad9252_control(
	input 					reset,	//low active
	input 					start,	//edge triggier
	input 					clk_spi,
	input [7:0] 			ch,
//	input 					pulse_da,
	input 					pulse_ad,
	input					adc_restart,
//	input [15:0] 			dac_datain,
	input [2:0]				switch,
	//input [15:0]			adc_datain,
	input 					data_aligned,
//	output  wire [3:0]		da_sync, 
//	output 	wire			da_sclk,
//	output 	wire			da_sdata,
//	output  wire 			da_done,
	output  wire 			ad_sclk,
	output  wire			ad_sdio,
	output  wire 			ad_csb,
	output  wire 			spi_9252_done,
	output  wire 			ad_test_cfg_done,

	output wire [4:0] 		state_9_1,
	
	output  wire 			busy_9252

	);

//	wire			dac_data;
//	wire			dac_clk;
//	wire			cs_dac_in;
	wire 			sclk_adc;
	wire 			sdio_adc;
	wire 			csb_adc;
	wire 			sync_rst;
	wire 			config_done;
	wire 			config_restart;
	wire 	 		spi_done_ad;
	wire [4:0] 		state_9;
	wire 			test_cfg_done;

	assign state_9_1 = state_9;
	
	spi_sync_rst spi_rst_inst
	(
		.clk					(clk_spi),
		.reset					(reset),
		.adc_restart 			(adc_restart),
		.sync_rst				(sync_rst),
		.sync_restart 			(sync_restart)	
    );


	reg 					sync_r1;
	reg 					sync_r2;
	reg 					sync_r3;
	wire 					async_align;
	wire 					sync_align;
	
	assign async_align = (~data_aligned) & sync_align;
	assign sync_align = sync_r3;

	always @(posedge data_aligned or posedge async_align) 
	begin 
		if(async_align) begin
			sync_r1 <= 1'b0;
		end else begin
			sync_r1 <= 1'b1;
		end
	end

	always @(posedge clk_spi) 
	begin 
		sync_r2 <= sync_r1;
		sync_r3 <= sync_r2;	
	end


	adc9252_spi adc9252_control
	(
		.clk_adc 				(clk_spi),
		.reset 					(sync_rst | sync_restart),
		.start 					(start),
		.data_aligned 			(sync_align),
		.pulse_ad 				(pulse_ad),
		//.adc_data 				(adc_datain),
		.sclk_adc 				(ad_sclk),
		.sdio_adc				(ad_sdio),
		.csb_adc				(ad_csb),
		.state_9 				(state_9),
		.test_cfg_done 			(test_cfg_done),
		.busy_9252				(busy_9252),
		.spi_done 				(spi_done_ad)
	);


	assign spi_9252_done = spi_done_ad;
	assign ad_test_cfg_done	 = test_cfg_done;
	
endmodule
