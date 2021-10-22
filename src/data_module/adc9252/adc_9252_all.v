`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/22 09:08:09
// Design Name: 
// Module Name: adc_9252_all
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

module adc_9252_all #
(
	parameter 				ADC_CHANEL = 8
	) 
(
	input 						reset,
	input 						soft_rst,
	input 						fifo_rst,
	input 						clk_200m,
	input [ADC_CHANEL-1:0] 		adc_a_data_p,
	input [ADC_CHANEL-1:0] 		adc_a_data_n,
	input 						adc_a_DCO_p,
	input 						adc_a_DCO_n,
	input 						adc_a_FCO_p,
	input 						adc_a_FCO_n,
	input [ADC_CHANEL-1:0] 		adc_b_data_p,
	input [ADC_CHANEL-1:0] 		adc_b_data_n,
	input 						adc_b_DCO_p,
	input 						adc_b_DCO_n,
	input 						adc_b_FCO_p,
	input 						adc_b_FCO_n,
	input [ADC_CHANEL-1:0] 		adc_c_data_p,
	input [ADC_CHANEL-1:0] 		adc_c_data_n,
	input 						adc_c_DCO_p,
	input 						adc_c_DCO_n,
	input 						adc_c_FCO_p,
	input 						adc_c_FCO_n,
	input [ADC_CHANEL-1:0] 		adc_d_data_p,
	input [ADC_CHANEL-1:0] 		adc_d_data_n,
	input 						adc_d_DCO_p,
	input 						adc_d_DCO_n,
	input 						adc_d_FCO_p,
	input 						adc_d_FCO_n,
	input 						ad_spi_done,			// Active high
	input 						soft_start,
	input 						ad_test_mode,
	input 						fifo_rd_clk,
	input [3:0] 				fifo_rden, 		// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	output 						fifo_empty,
	output 						dco_done,
	output 						data_aligned,
	output 						soft_rst_sync,
	output  					spi_done_sync,
	output  					reset_sync,
	output 						adc_a_fclk,
	output 						adc_b_fclk,
	output 						adc_c_fclk,
	output 						adc_d_fclk,
	output 						fifo_flag,
	output [3:0] 				wren_fsm,
	output [8:0] 				delay_fsm_o,
	output [7:0] 				one_adc_aligned,
	output [127:0]				adc_a_data_para,
	output [127:0]				adc_b_data_para,
	output [127:0]				adc_c_data_para,
	output [127:0]				adc_d_data_para
);

	wire [3:0] 					fifo_wren; 	// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	wire [3:0] 					fifo_full; 	// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	wire [3:0] 					empty_flag;	// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	wire [3:0] 					dco_done_buf; 	// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	wire [3:0] 					aligned; 	// [0]--adc_A,[1]--adc_B,[2]--adc_C,[3]--adc_D
	wire [ADC_CHANEL*14-1:0] 	adc_a_data;
	wire [ADC_CHANEL*14-1:0] 	adc_b_data;
	wire [ADC_CHANEL*14-1:0] 	adc_c_data;
	wire [ADC_CHANEL*14-1:0] 	adc_d_data;
	wire 						fifo_a_rst;
	wire 						fifo_b_rst;
	wire 						fifo_c_rst;
	wire 						fifo_d_rst;
	wire [3:0] 					ad_soft_rst_sync;
	wire [3:0] 					ad_reset_sync;
	wire [3:0] 					ad_spi_done_sync;

	assign soft_rst_sync 	= soft_rst;
	assign spi_done_sync 	= data_aligned ? 0 : 1;;
	assign reset_sync 		= fifo_rst;
	assign fifo_flag 		= empty_flag[2];
	assign wren_fsm 		= {aligned[3],aligned[2],aligned[1],aligned[0]};


	(* IODELAY_GROUP = "dco_delay1" *)
	IDELAYCTRL IDELAYCTRL_inst1 
	(
		.RDY 						(),  	 			// 1-bit output: Ready output
		.REFCLK 					(clk_200m), 		// 1-bit input: Reference clock input
		.RST 						(reset)        		// 1-bit input: Active high reset input
	);
	(* IODELAY_GROUP = "dco_delay2" *)
	IDELAYCTRL IDELAYCTRL_inst2 
	(
		.RDY 						(),  	 			// 1-bit output: Ready output
		.REFCLK 					(clk_200m), 		// 1-bit input: Reference clock input
		.RST 						(reset)        		// 1-bit input: Active high reset input
	);

	ad9252_wrap #
	(
		.ADC_CHANEL 				(ADC_CHANEL),
		.DCO_DELAY_TAPS				(16),
		.FCO_DELAY_TAPS				(16),
		.DATA_DLY_TAPS 				(0)
	)	
	adc_a_9252_inst
	(
	    .reset						(reset),
	    .soft_rst 					(soft_rst),
	//	.clk_200m					(clk_200m),
		.adc_data_p					(adc_a_data_p),
		.adc_data_n					(adc_a_data_n),
		.adc_DCO_p					(adc_a_DCO_p),
		.adc_DCO_n					(adc_a_DCO_n),
		.adc_FCO_p					(adc_a_FCO_p),
		.adc_FCO_n					(adc_a_FCO_n),
		.ad_spi_done 				(1'b1),
		.ad_test_mode 				(ad_test_mode),
		.soft_start 				(soft_start),
		.data_fifo_full				(fifo_full[0]),
		.data_fifo_wren				(fifo_wren[0]),
		.adc_fclk					(adc_a_fclk),
		.data_aligned 				(aligned[0]),
		.dco_done 					(dco_done_buf[0]),
		.soft_rst_sync				(ad_soft_rst_sync[0]),
		.spi_done_sync				(ad_spi_done_sync[0]),
		.reset_sync					(ad_reset_sync[0]),
		.fco_pattern_ila			(pattern_a),
		.dco_pattern_ila			(one_adc_aligned),
		.align_fsm 					(),
		.delay_fsm_o 				(delay_fsm_o),
		.adc_data_allch				(adc_a_data)
    );

	fifo_128x64 adc_a_data_fifo
	(
		.wr_clk 					(adc_a_fclk),
		.rd_clk 					(fifo_rd_clk),
		.rst 						(fifo_rst| soft_rst),
		.din 						({16'hEEAA,adc_a_data}),
		.full 						(fifo_full[0]),
		.wr_en 						(fifo_wren[0]),
		.dout 						(adc_a_data_para),
		.empty 						(empty_flag[0]),
		.rd_en 						(fifo_rden[0])
	);

    ad9252_wrap #
	(
		.ADC_CHANEL 				(ADC_CHANEL),
		.DCO_DELAY_TAPS				(16),
		.FCO_DELAY_TAPS				(16),
		.DATA_DLY_TAPS 				(0)
		)
	adc_b_9252_inst
	(
	    .reset						(reset),
	    .soft_rst 					(soft_rst),
	//	.clk_200m					(clk_200m),
		.adc_data_p					(adc_b_data_p),
		.adc_data_n					(adc_b_data_n),
		.adc_DCO_p					(adc_b_DCO_p),
		.adc_DCO_n					(adc_b_DCO_n),
		.adc_FCO_p					(adc_b_FCO_p),
		.adc_FCO_n					(adc_b_FCO_n),
		.ad_spi_done 				(1'b1),
		.ad_test_mode 				(ad_test_mode),
		.soft_start 				(soft_start),
		.data_fifo_full				(fifo_full[1]),
		.data_fifo_wren				(fifo_wren[1]),
		.adc_fclk					(adc_b_fclk),
		.data_aligned 				(aligned[1]),
		.dco_done 					(dco_done_buf[1]),
		.soft_rst_sync				(ad_soft_rst_sync[1]),
		.spi_done_sync				(ad_spi_done_sync[1]),
		.reset_sync					(ad_reset_sync[1]),
		.fco_pattern_ila			(pattern_b),
		.dco_pattern_ila			(),
		.align_fsm 					(),
		.adc_data_allch				(adc_b_data)
    );

	fifo_128x64 adc_b_data_fifo
	(
		.wr_clk 					(adc_b_fclk),
		.rd_clk 					(fifo_rd_clk),
		.rst 						(fifo_rst| soft_rst),
		.din 						({16'hEEBB,adc_b_data}),
		.full 						(fifo_full[1]),
		.wr_en 						(fifo_wren[1]),
		.dout 						(adc_b_data_para),
		.empty 						(empty_flag[1]),
		.rd_en 						(fifo_rden[1])
	);

    ad9252_wrap #
	(
		.ADC_CHANEL 				(ADC_CHANEL),
		.DCO_DELAY_TAPS				(16),
		.FCO_DELAY_TAPS				(8),
		.DATA_DLY_TAPS 				(0)
		)
	adc_c_9252_inst
	(
	    .reset						(reset),
	    .soft_rst 					(soft_rst),
	//	.clk_200m					(clk_200m),
		.adc_data_p					(adc_c_data_p),
		.adc_data_n					(adc_c_data_n),
		.adc_DCO_p					(adc_c_DCO_p),
		.adc_DCO_n					(adc_c_DCO_n),
		.adc_FCO_p					(adc_c_FCO_p),
		.adc_FCO_n					(adc_c_FCO_n),
		.ad_spi_done 				(1'b1),
		.ad_test_mode 				(ad_test_mode),
		.soft_start 				(soft_start),
		.data_fifo_full				(fifo_full[2]),
		.data_fifo_wren				(fifo_wren[2]),
		.adc_fclk					(adc_c_fclk),
		.data_aligned 				(aligned[2]),
		.dco_done 					(dco_done_buf[2]),
		.soft_rst_sync				(ad_soft_rst_sync[2]),
		.spi_done_sync				(ad_spi_done_sync[2]),
		.reset_sync					(ad_reset_sync[2]),
		.fco_pattern_ila			(pattern_c),
		.dco_pattern_ila			(),
		.align_fsm 					(),
		.adc_data_allch				(adc_c_data)
    );

	fifo_128x64 adc_c_data_fifo
	(
		.wr_clk 					(adc_c_fclk),
		.rd_clk 					(fifo_rd_clk),
		.rst 						(fifo_rst| soft_rst),
		.din 						({16'hEECC,adc_c_data}),
		.full 						(fifo_full[2]),
		.wr_en 						(fifo_wren[2]),
		.dout 						(adc_c_data_para),
		.empty 						(empty_flag[2]),
		.rd_en 						(fifo_rden[2])
	);

    ad9252_wrap #
	(
		.ADC_CHANEL 				(ADC_CHANEL),
		.DCO_DELAY_TAPS				(16),
		.FCO_DELAY_TAPS				(16),
		.DATA_DLY_TAPS 				(0)
		)
	adc_d_9252_inst
	(
	    .reset						(reset),
	    .soft_rst 					(soft_rst),
	//	.clk_200m					(clk_200m),
		.adc_data_p					(adc_d_data_p),
		.adc_data_n					(adc_d_data_n),
		.adc_DCO_p					(adc_d_DCO_p),
		.adc_DCO_n					(adc_d_DCO_n),
		.adc_FCO_p					(adc_d_FCO_p),
		.adc_FCO_n					(adc_d_FCO_n),
		.ad_spi_done 				(1'b1),
		.ad_test_mode 				(ad_test_mode),
		.soft_start 				(soft_start),
		.data_fifo_full				(fifo_full[3]),
		.data_fifo_wren				(fifo_wren[3]),
		.adc_fclk					(adc_d_fclk),
		.data_aligned 				(aligned[3]),
		.dco_done 					(dco_done_buf[3]),
		.soft_rst_sync				(ad_soft_rst_sync[3]),
		.spi_done_sync				(ad_spi_done_sync[3]),
		.reset_sync					(ad_reset_sync[3]),
		.fco_pattern_ila			(pattern_d),
		.dco_pattern_ila			(),
		.align_fsm 					(),
		.adc_data_allch				(adc_d_data)
    );

    fifo_128x64 adc_d_data_fifo
	(
		.wr_clk 					(adc_d_fclk),
		.rd_clk 					(fifo_rd_clk),
		.rst 						(fifo_rst| soft_rst),
		.din 						({16'hEEDD,adc_d_data}),
		.full 						(fifo_full[3]),
		.wr_en 						(fifo_wren[3]),
		.dout 						(adc_d_data_para),
		.empty 						(empty_flag[3]),
		.rd_en 						(fifo_rden[3])
	);

	assign fifo_empty 	= empty_flag[0] | empty_flag[1] | empty_flag[2] | empty_flag[3];
	assign dco_done 	= dco_done_buf[0] & dco_done_buf[1] & dco_done_buf[2] & dco_done_buf[3];
	assign data_aligned = aligned[0] & aligned[1] & aligned[2] & aligned[3];

endmodule
