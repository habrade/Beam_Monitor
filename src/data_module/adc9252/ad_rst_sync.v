`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/30 16:10:21
// Design Name: 
// Module Name: adc9252_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:  Active HIGH
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ad_signal_sync (
	input 					clk_dco_div,    // Clock
	input 					clk_dco_fc, // Clock Enable
	input 					reset,  // Asynchronous reset active low
	input 					soft_rst,
	input 					ad_spi_done,
	input 					ad_test_mode,
	output 					dco_rst,
	output 					dco_fc_rst,
	output 					dco_soft_rst,
	output 					dco_test_mode,
	output 					dco_spi_done  // Has synced to dco
);


	
	reg 					sync_r1;
	reg 					sync_r2;
	reg 					sync_r3;
	wire 					async_rst_fco;
	reg 					sync_r4;
	reg 					sync_r5;
	reg 					sync_r6;
	wire 					async_rst_dco;
	wire 					reset_buf;
	reg 					sync_r7;
	reg 					sync_r8;
	reg 					sync_r9;
	wire 					spi_done_dco;
	wire 					spi_done_buf;
	reg 					sync_r10;
	reg 					sync_r11;
	reg 					sync_r12;
	wire 					soft_rst_dco;
	wire 					soft_rst_buf;
	reg 					sync_r13;
	reg 					sync_r14;
	reg 					sync_r15;
	wire 					test_done_dco;
	wire 					test_done_buf;

	assign async_rst_fco = (~reset) & dco_fc_rst;
	assign dco_fc_rst = sync_r3;

	always @(posedge reset or posedge async_rst_fco) 
	begin 
		if(async_rst_fco) begin
			sync_r1 <= 1'b0;
		end else begin
			sync_r1 <= 1'b1;
		end
	end

	always @(posedge clk_dco_fc) 
	begin 
		sync_r2 <= sync_r1;
		sync_r3 <= sync_r2;	
	end
	//------------------------------------------//
	assign async_rst_dco = (~reset) & reset_buf;
	assign reset_buf = sync_r6;

	always @(posedge reset or posedge async_rst_dco) 
	begin 
		if(async_rst_dco) begin
			sync_r4 <= 1'b0;
		end else begin
			sync_r4 <= 1'b1;
		end
	end

	always @(posedge clk_dco_div) 
	begin 
		sync_r5 <= sync_r4;
		sync_r6 <= sync_r5;	
	end
	//--------------------------------------------//
	assign spi_done_dco = (~ad_spi_done) & spi_done_buf;
	assign spi_done_buf = sync_r9;

	always @(posedge ad_spi_done or posedge spi_done_dco) 
	begin 
		if(spi_done_dco) begin
			sync_r7 <= 1'b0;
		end else begin
			sync_r7 <= 1'b1;
		end
	end

	always @(posedge clk_dco_div) 
	begin 
		sync_r8 <= sync_r7;
		sync_r9 <= sync_r8;	
	end
	//--------------------------------------------//
	assign soft_rst_dco = (~soft_rst) & soft_rst_buf;
	assign soft_rst_buf = sync_r12;

	always @(posedge soft_rst or posedge soft_rst_dco) 
	begin 
		if(soft_rst_dco) begin
			sync_r10 <= 1'b0;
		end else begin
			sync_r10 <= 1'b1;
		end
	end

	always @(posedge clk_dco_div) 
	begin 
		sync_r11 <= sync_r10;
		sync_r12 <= sync_r11;	
	end
	//--------------------------------------------//

	//--------------------------------------------//
	assign test_done_dco = (~ad_test_mode) & test_done_buf;
	assign test_done_buf = sync_r15;

	always @(posedge ad_test_mode or posedge test_done_dco) 
	begin 
		if(test_done_dco) begin
			sync_r13 <= 1'b0;
		end else begin
			sync_r13 <= 1'b1;
		end
	end

	always @(posedge clk_dco_div) 
	begin 
		sync_r14 <= sync_r13;
		sync_r15 <= sync_r14;	
	end
	//----------------------------------------//

/*	always @(posedge clk_dco_div) 
	begin : proc_reset
		sync_r4	<= reset;
		sync_r5	<= sync_r4;
		sync_r6 <= sync_r5;
	end
*/
	FDPE #
	(
		.INIT(1'b1)
		) 
	reset_FDPE
	(
		.C					(clk_dco_div),
		.CE					(1),
		.PRE				(reset_buf),
		.D					(0),
		.Q					(dco_rst)
	);

/*	always @(posedge clk_dco_div) 
	begin : proc_reset
		sync_r10	<= reset;
		sync_r11	<= sync_r10;
		sync_r12 	<= sync_r11;
	end
*/
	FDPE #
	(
		.INIT(1'b1)
		) 
	soft_rst_FDPE
	(
        .C					(clk_dco_div),
        .CE					(1),
        .PRE				(soft_rst_buf),
        .D					(0),
        .Q					(dco_soft_rst)
    );

/*	always @(posedge clk_dco_div) 
	begin : proc_spi_done
		sync_r7	<= ad_spi_done;
		sync_r8	<= sync_r7;
		sync_r9 <= sync_r8;
	end
*/
	FDPE #
	(
		.INIT(1'b1)
		) 
	spi_done_FDPE
	(
        .C					(clk_dco_div),
        .CE					(1),
        .PRE				(spi_done_buf),
        .D					(0),
        .Q					(dco_spi_done)
    );

    FDPE #
	(
		.INIT(1'b1)
		) 
	test_mode_FDPE
	(
        .C					(clk_dco_div),
        .CE					(1),
        .PRE				(test_done_buf),
        .D					(0),
        .Q					(dco_test_mode)
    );

//	assign dco_soft_rst = soft_rst_buf;
//	assign dco_spi_done = spi_done_buf;
//	assign dco_rst = reset_buf;

endmodule