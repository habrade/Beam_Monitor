`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/03/22 09:08:09
// Design Name: 
// Module Name: ad_data_module
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

module ad_data_module #
(
	parameter 				ADC_CHANEL 		= 4
	)
 (
	input 					clk_200m,
	input 					clk_100m,
	input 					clk_10m,
	input 					reset,  // Asynchronous reset active high
	input [ADC_CHANEL-1:0]	marker_a, // Indicate the first pixel of Topmetal
	input 					soft_rst,
	input 					soft_path_rst,
	input 					soft_pack_start,
	input [ADC_CHANEL-1:0]	adc_data_p,
 	input [ADC_CHANEL-1:0]	adc_data_n,
 	input 					adc_DCO_p,
 	input 					adc_DCO_n,
 	input 					adc_FCO_p,
	input 					adc_FCO_n,
	input 					ad_test_mode,
	input [3:0]				board_number,
	input [3:0] 			chip_number,
//	input 					ctrl_rd_req,
//	input 					ctrl_rd_clk,
	input 					resync,
	input [15:0] 			data_type,
	input [15:0] 			time_high,
	input [15:0] 			time_mid,
	input [15:0] 			time_low,
	input [31:0] 			time_usec,
	input [15:0] 			chip_cnt,
//	input 					compress_flag,
	output  				adc_dco_done,
	output 					data_aligned,
//	output  				empty_ctrl,
	//output [13:0] 			fco_pattern,
	output [8:0] 			dp_status,
	
	  //  DATA FIFO
   output data_fifo_rst ,       
   output data_fifo_wr_clk   ,  
  output  data_fifo_wr_en ,     
   output [31:0] data_fifo_wr_din,     
//  input  final_data_fifo_full     ,   
//  input  data_fifo_almost_full 
//	output [31:0] 			data_bus
	// DEBUG
	output adc_fclk_o

);

 	
	wire [127:0] 				header;
	wire [127:0] 				tail;
	
 	wire 						adc_fclk;
 	wire 						test_mode_sync;
 	wire [14*ADC_CHANEL-1:0]	adc_data_bus;
 	wire [13:0] 				compressed_data[ADC_CHANEL-1:0];
	wire 						aligned;
	wire [31:0] 				interm_data[ADC_CHANEL-1:0];
	wire 						full_flag;
	wire 						reset_intl;
	wire [ADC_CHANEL-1:0] 		data_fifo_full;
	wire [ADC_CHANEL-1:0] 		data_fifo_wren;
	wire 				 		dco_done;
	wire [ADC_CHANEL-1:0] 		fifo_empty;
	wire [ADC_CHANEL*32-1:0] data_out;
	wire 						empty_flag;
	wire [ADC_CHANEL-1:0] fifo_rden;
	wire [31:0] 				data_intern;
	wire [ADC_CHANEL-1:0]		bridge_full;
	wire [ADC_CHANEL-1:0] 		bridge_empty;
	wire [13:0] 				bridge_data[ADC_CHANEL-1:0];
	wire [ADC_CHANEL-1:0] 		bridge_rden;
	wire [ADC_CHANEL-1:0] 		bridge_wren;
	wire 						ctrl_wr_req;
	//ila
	//wire [13:0] 				pattern_fco;
	wire [8:0] 					d_status[ADC_CHANEL-1:0];
	wire [31:0] 				frame_num[ADC_CHANEL-1:0];
	
	// DEBUG
	assign adc_fclk_o = adc_fclk;
	
	//assign data_flag = aligned[0];

	assign data_aligned = aligned;
	
	//assign fco_pattern = pattern_fco;
	//assign dco_align = {bridge_wren[0][1],bridge_wren[1][1]};
	assign dp_status = d_status[0][1];

	(* IODELAY_GROUP = "AD_DEALY" *)
	IDELAYCTRL IDELAYCTRL_inst
	(
		.RDY 						(),  	 			// 1-bit output: Ready output
		.REFCLK 					(clk_200m), 		// 1-bit input: Reference clock input
		.RST 						(reset)        		// 1-bit input: Active high reset input
	);

/*	reg 					sync_r1;
	reg 					sync_r2;
	reg 					sync_r3;
	wire 					async_start;
	wire 					sync_start;
	//------------------------------------------//
	assign async_start = (~soft_start) & sync_start;
	assign sync_start = sync_r3;

	always @(posedge soft_start or posedge async_start) 
	begin 
		if(async_start) begin
			sync_r1 <= 1'b0;
		end else begin
			sync_r1 <= 1'b1;
		end
	end

	always @(posedge clk_100m) 
	begin 
		sync_r2 <= sync_r1;
		sync_r3 <= sync_r2;	
	end
	*/

				ad9252_wrap #
				(
					.ADC_CHANEL 				(ADC_CHANEL),
					.DCO_DELAY_TAPS				(16),
					.FCO_DELAY_TAPS				(16),
					.DATA_DLY_TAPS 				(0)
				)	
				adc_9252_inst
				(
				    .reset						(reset),
				    .soft_rst 					(soft_rst),
				//	.clk_200m					(clk_200m),
					.adc_data_p					(adc_data_p[3:0]),
					.adc_data_n					(adc_data_n[3:0]),
					.adc_DCO_p					(adc_DCO_p),
					.adc_DCO_n					(adc_DCO_n),
					.adc_FCO_p					(adc_FCO_p),
					.adc_FCO_n					(adc_FCO_n),
					.ad_spi_done 				(1'b1),
					.ad_test_mode 				(ad_test_mode),
					.soft_start 				(1'b0), // Active LOW, For board test, if not use, please band with GND
					.data_fifo_full				(full_flag),
					.data_fifo_wren				(),
					.adc_fclk					(adc_fclk),
					.data_aligned 				(aligned),
					.dco_done 					(dco_done),
					.soft_rst_sync				(),
					.spi_done_sync				(),
					.test_mode_sync 			(test_mode_sync),
					.reset_sync					(reset_intl),
					//.fco_pattern_ila			(pattern_fco),
					//.dco_pattern_ila			(one_adc_aligned),
					.align_fsm 					(),
					.delay_fsm_o 				(delay_fsm_o),
					.adc_data_allch				(adc_data_bus)
			    );


	assign adc_dco_done = dco_done;

		header_tail_gen header_tail
		(
			.clk_10m				(clk_10m),    	// Clock
			.clk_100m				(clk_100m),		//
			.reset					(reset),  		// Asynchronous reset active low
			.resync					(resync),		// From software, sync the date and time,
			.data_type				(data_type),	//
			.frame_num				(frame_num[0][0]),
			.time_high				(time_high),  	// Contains year, months
			.time_mid				(time_mid),		// date, hours
			.time_low				(time_low), 	// minutes, seconds
			.time_usec 				(time_usec),
			.chip_num				(chip_cnt),		// The upper 8 bits are the chip end number, and the lower eight bits are the chip start number.
			.board_num				(board_number),
			.header					(header),
			.tail 					(tail)
		);
	generate
		begin : operate_amount
			genvar k;
				for(k = 0; k < ADC_CHANEL; k = k + 1) begin 
					data_compress compress_inst
					(
						.ad_fco_clk					(adc_fclk),    		// ADC frame clock
						.reset						(reset_intl | soft_path_rst),  				// Asynchronous reset active high
						.marker_a					(marker_a[k]), 			// Indicate the first pixel
						.data_aligned 				(data_aligned),
						.adc_data					(adc_data_bus[14*(k+1)-1:14*k]), // One channel data of ADC
						.data_valid					(bridge_wren[k]),
						.compressed_data			(compressed_data[k])	// Have compressed
					);

					fifo_bridge_14x64 fifo_bridge
					(
						.wr_clk 					(adc_fclk),
						.rd_clk 					(clk_200m),
						.rst 						(reset | soft_path_rst),
						.din 						(compressed_data[k]),
						.full 						(bridge_full[k]),
						.wr_en 						(bridge_wren[k]),
						.dout 						(bridge_data[k]),
						.empty 						(bridge_empty[k]),
						.rd_en 						(bridge_rden[k])
					);
						
					data_packaging packaging_inst
					(
						.clk_200m					(clk_200m),    			// Clock
						.reset						(reset | soft_path_rst),  				// Asynchronous reset active high
						.data_valid					(~bridge_empty[k]),		// indicate the data has been prepared
						.trans_start				(1'b0), 			// Transmit start signal
						.aligned					(aligned),			// Data has aligned
						.input_data					({2'b00,bridge_data[k]}),// One channel data bus
						.board_number				(board_number), 		// The IP words
						.chip_number				(k),			// Topmetal's number
						.header 					(header[32*((3-k)+1)-1 -:32]),
						.tail 						(tail[32*((3-k)+1)-1 -:32]),								  
						.fifo_wren					(data_fifo_wren[k]), 		// 
						.fifo_rden 					(bridge_rden[k]),
						.dp_status 					(d_status[k]),
						.frame_num 					(frame_num[k]),
						.out_data					(interm_data[k])		// The output data bus
					);

					fifo_32x128 adc_data_fifo
					(
						.wr_clk 					(clk_200m),
						.rd_clk 					(clk_100m),
						.rst 						(reset | soft_path_rst),
						.din 						(interm_data[k]),
						.full 						(data_fifo_full[k]),
						.wr_en 						(data_fifo_wren[k]),
						.dout 						(data_out[32*(k+1)-1:32*k]),
						.empty 						(fifo_empty[k]),
						.rd_en 						(fifo_rden[k])
					);
				end

				assign full_flag = 	data_fifo_full[0] | data_fifo_full[1] | data_fifo_full[2] |  data_fifo_full[3];						 

			end
	endgenerate

	assign empty_flag = fifo_empty[0] | fifo_empty[1] | fifo_empty[2] | fifo_empty[3];
	data_delivery #
	(
		.ADC_CHANEL 		(ADC_CHANEL)
		)
	deliver_inst
	(
		.clk_200m				(clk_100m),    			// Clock
		.reset					(reset | soft_path_rst), 	// Asynchronous reset active low
//		.trans_start			(ctrl_rd_req), // Transmit start,come from PC
		.data_in				(data_out), 			// data from FIFO
		.fifo_empty				(empty_flag), 			// front FIFO empty signal
		.fifo_rden				(fifo_rden), 			// front FIFO read enable
		.fifo_wren 				(data_fifo_wr_en),
		.data_out				(data_fifo_wr_din)
	);
	
	assign data_fifo_wr_clk = clk_100m;
	assign data_fifo_rst = reset | soft_path_rst;

//	fifo_32x128 ctrl_data_buf
//	(
//		.wr_clk 				(clk_100m),
//		.rd_clk 				(ctrl_rd_clk),
//		.rst 					(reset | soft_path_rst),
//		.din 					(data_intern),
//		.full 					(),
//		.wr_en 					(ctrl_wr_req),
//		.dout 					(data_bus),
//		.empty 					(empty_ctrl),
//		.rd_en 					(ctrl_rd_req)
//	);


endmodule