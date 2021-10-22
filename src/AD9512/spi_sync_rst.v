`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/10 16:52:54
// Design Name: 
// Module Name: spi_sync_rst
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


module spi_sync_rst(
    input 		clk,
    input 		reset,
    input 		adc_restart,
    output wire sync_rst,
    output wire sync_restart
    );

	wire 		async_rst_10;
	reg 		sync_r3;
	reg 		sync_r2;
	reg 		sync_r1;
	wire 		async_restart;
	reg 		sync_r6;
	reg 		sync_r5;
	reg 		sync_r4;
	// Sync the system reset signal to DA clock
	//-----------------------------------------//
	assign async_rst_10 = (~reset) & sync_rst;
	assign sync_rst = sync_r3;

	always @(posedge reset or posedge async_rst_10) 
	begin 
		if(async_rst_10) begin
			sync_r1 <= 1'b0;
		end else begin
			sync_r1 <= 1'b1;
		end
	end

	always @(posedge clk) 
	begin 
		sync_r2 <= sync_r1;
		sync_r3 <= sync_r2;	
	end
	//------------------------------------------//

	//-----------------------------------------//
	assign async_restart = (~adc_restart) & sync_restart;
	assign sync_restart = sync_r6;

	always @(posedge adc_restart or posedge async_restart) 
	begin 
		if(async_restart) begin
			sync_r4 <= 1'b0;
		end else begin
			sync_r4 <= 1'b1;
		end
	end

	always @(posedge clk) 
	begin 
		sync_r5 <= sync_r4;
		sync_r6 <= sync_r5;	
	end
	//------------------------------------------//

endmodule
