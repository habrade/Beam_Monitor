`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/22 09:08:09
// Design Name: 
// Module Name: ad9252_wrap
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
module ad9252_wrap #
	(
		parameter 			ADC_CHANEL 		= 4,
		parameter          	DCO_DELAY_TAPS 	= 16,
		parameter 			FCO_DELAY_TAPS 	= 16,
		parameter 			DATA_DLY_TAPS 	= 16
		)
	(
	input 					reset,
	input 					soft_rst,
	//input 					clk_200m,
	input [ADC_CHANEL-1:0] 	adc_data_p,
	input [ADC_CHANEL-1:0] 	adc_data_n,
	input 					adc_DCO_p,
	input 					adc_DCO_n,
	input 					adc_FCO_p,
	input 					adc_FCO_n,
	input 					ad_spi_done,			// Active high
	input 					ad_test_mode, 			// Indicate ADC device self-test done
	input 					data_fifo_full,			// Indicate external FIFO is FULL
	input 					soft_start, 			// From PC, preview module is Contrl_Interface
	output 					data_fifo_wren, 		// External FIFO write enable
	output 					adc_fclk, 				// Out Frame clock, 7-divide from Data clock
	output wire 			dco_done, 				// Indicate Data clock is ALIGNED
	output wire 			data_aligned,			// Indicate the data has aligned.
	output wire				soft_rst_sync,			//
	output wire 			spi_done_sync,
	output wire 			test_mode_sync,
	output wire 			reset_sync,
	//output wire	[13:0]		fco_pattern_ila,
	//output wire [13:0]		dco_pattern_ila,
	output wire [3:0] 		align_fsm,
	output wire [8:0] 		delay_fsm_o,
	output reg [ADC_CHANEL*14-1:0]		adc_data_allch		
	);
	
	

	wire 					adc_dco;	
	wire 					adc_fco;
	wire 					adc_dco_clk;
	wire [ADC_CHANEL-1:0]	adc_data_buf;
	wire 					rst_dco;
	wire 					rst_dco_fc;

	wire [4:0] 				delay_tap_cnt;
	//wire [7:0] 				dco_align_word;
	wire 					adc_fco_ref;
	wire 					dco_aligned;
	wire 					fco_bitslip;
	wire 					clk_en;
	wire 					idelayctrl_rdy;
	wire 					dco_soft_rst;
	wire					dco_spi_done;
	wire 					dco_test_mode;
	wire [13:0] 			fco_pattern;
	wire [13:0] 			adc_data_para_out[ADC_CHANEL-1:0];
	wire 					fco_aligned;
	wire [ADC_CHANEL-1:0]	delay_ld;
	wire [ADC_CHANEL-1:0]	delay_ce;
	wire [ADC_CHANEL-1:0]	delay_inc;
	wire [ADC_CHANEL-1:0] 	dat_bitslip;
	wire [4:0]				cntvaluein[ADC_CHANEL-1:0];
	wire [ADC_CHANEL-1:0] 	aligned;
	wire [8:0] 				delay_fsm[ADC_CHANEL-1:0];

	diff2single #
	(
		.ADC_CHANEL 		(ADC_CHANEL)
	) 
	adc_diff2single_inst
	(
		.ad_DCO_p			(adc_DCO_p),
		.ad_DCO_n			(adc_DCO_n),
		.ad_FCO_p			(adc_FCO_p),
		.ad_FCO_n			(adc_FCO_n),
		.ad_data_p			(adc_data_p),
		.ad_data_n			(adc_data_n),
		.adc_dco			(adc_dco),
		.adc_fco			(adc_fco),
		.adc_data			(adc_data_buf)
	);

	ad_signal_sync signal_sync
	(
		.clk_dco_div		(adc_fco_ref),    	// Clock
		.clk_dco_fc			(adc_fco_ref), 		// Clock Enable
		.reset				(reset),  		// Asynchronous reset active high
		.soft_rst 			(soft_rst),
		.ad_spi_done 		(ad_spi_done),
		.ad_test_mode 		(ad_test_mode),
		.dco_rst			(rst_dco),
		.dco_fc_rst			(rst_dco_fc),
		.dco_soft_rst 		(dco_soft_rst),
		.dco_test_mode 		(dco_test_mode),
		.dco_spi_done		(dco_spi_done)
	);

	bitslip_wren bitslip_wren
	(
		.ad_dco_fc			(adc_fco_ref),    	// Clock
		.reset				(rst_dco_fc),  	// Asynchronous reset active low
		.fco_pattern		(fco_pattern),
		.data_aligned 		(data_aligned),
		.data_fifo_full		(data_fifo_full),
		.spi_done			(spi_done),
		.bit_slip			(fco_bitslip),
		.fco_aligned 		(fco_aligned),
		.clk_en 			(dco_aligned),
		//.clk_en 			(1'b1),
		.data_fifo_wren		(data_fifo_wren),
		.state_wren 		()
	);

	ad9252_dco #
	(
		.C_StatTaps			(DCO_DELAY_TAPS)
		) 
	ad9252_dco_sync
	(
		.BitClk				(adc_dco),
		.BitClkRst			(rst_dco | ~dco_spi_done | dco_soft_rst),
		//.BitClkRst			(rst_dco),
		.BitClkEna			(1'b1),
		.BitClkReSync		(1'b0),
		.BitClk_MonClkOut	(adc_dco_clk),
		.BitClk_MonClkIn	(adc_dco_clk),
		.BitClk_RefClkOut	(adc_fco_ref),
		.BitClk_RefClkIn	(adc_fco_ref),
		.BitClkAlignWarn	(),
		.BitClkInvrtd		(),
		//.BitClkPattern		(dco_pattern_ila),
		.BitClkFsm			(),
		.BitClkDone			(dco_aligned)
	);

/*	BUFR #
	(
		.BUFR_DIVIDE			("7"), 					// Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
		.SIM_DEVICE				("7SERIES") 			// Must be set to "7SERIES"
	)
	BUFR_dco_fc
	(
		.O						(adc_fco_ref), 	// 1-bit output: Clock output port
		.CE						(1'b1), 				// 1-bit input: Active high, clock enable (Divided modes only)
		.CLR					(1'b0), 					// 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I 						(adc_dco) 			// 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);
*/


	ad9252_fco #
	(
		.FCO_DELAY_TAPS		(FCO_DELAY_TAPS)
		) 
	ad9252_fco_sync
	(
		.adc_fco			(adc_fco),   			// Clock
		.reset				(dco_soft_rst | rst_dco),  			// Asynchronous reset active low
		//.reset				(~dco_spi_done | dco_soft_rst),
		.ad_dco_fc			(adc_fco_ref),
		.ad_dco				(adc_dco_clk),
		.bit_slip			(fco_bitslip),
		.clk_en 			(dco_aligned),
		//.clk_en 			(1'b1),
		.fco_pattern		(fco_pattern)		
	);

	generate
		begin 
			genvar	i;
			for (i = 0; i < ADC_CHANEL; i = i + 1) 
			begin
				ad9252_data # 
				(
					.DATA_DLY_TAPS 		(DATA_DLY_TAPS)
					)
				ad9252_data_inst
				(
					.ad_dco 			(adc_dco_clk),    		// Clock dco
					.ad_dco_fc 			(adc_fco_ref), 			// Clock fc from dco
					.reset				(dco_soft_rst | rst_dco),  			// Asynchronous reset active low
					.ad_data			(adc_data_buf[i]),		// ADC serial data in
					.bit_slip			(fco_bitslip | dat_bitslip[i]), 
					.clk_en 			(dco_aligned),
					//.clk_en 			(1'b1),
					.delay_ld			(delay_ld[i]),
					.delay_ce			(delay_ce[i]),
					.delay_inc			(delay_inc[i]),
					.cntvaluein 		(cntvaluein[i]),
					.ad_data_para		(adc_data_para_out[i]) 	// ADC parallel data out
				);
				data_align_fsm data_delay_inst 
				(
					.clk_ref			(adc_fco_ref),    // Clock
					.reset				(dco_soft_rst | rst_dco),  // Asynchronous reset active low
					.data_pattern		(adc_data_para_out[i]),
					.ad_test_mode 		(dco_test_mode),
					.fco_aligned		(fco_aligned),
					.soft_start 		(soft_start), 		// For board test, if not use, please band with GND
					.idelay_ld			(delay_ld[i]),
					.idelay_ce			(delay_ce[i]),
					.idelay_inc			(delay_inc[i]),
					.dat_bitslip 		(dat_bitslip[i]),
					.cnt_value			(cntvaluein[i]),
					.dat_aligned		(aligned[i]),
					.delay_fsm 			(delay_fsm[i])
				);
			end
		end
	endgenerate
	
	always @(*) 
	begin : proc_data_out
		integer 	i;
		for ( i = 0; i < ADC_CHANEL; i = i + 1) 
		begin
			adc_data_allch[(14*(i+1)-1) -: 14] <= adc_data_para_out[i];
		end	
	end

	assign adc_fclk = adc_fco_ref;
	assign dco_done = dco_aligned;
	assign adc_dco_lia = adc_dco_clk;
 	assign adc_dco_align = adc_dco_clk;
 //	assign fco_pattern_ila = delay_fsm[0];
 	assign soft_rst_sync = dco_soft_rst;
 	assign spi_done_sync = dco_spi_done;
 	assign test_mode_sync = dco_test_mode;
	assign reset_sync = rst_dco;
	assign data_aligned = aligned[0] & aligned[1] & aligned[2] & aligned[3];
	//assign data_aligned = aligned[0] & aligned[5] &  aligned[7];						
    //assign fco_pattern_ila = {aligned[3], aligned[2], aligned[1], aligned[0]};
	assign align_fsm = {3'b000,fco_aligned};
	assign delay_fsm_o = delay_fsm[3];
endmodule
