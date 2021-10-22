`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 15:59:16
// Design Name: 
// Module Name: diff2single
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


module diff2single #
	(
		parameter 			ADC_CHANEL = 4
		)
	(
	input wire						ad_DCO_p,
	input wire						ad_DCO_n,
	input wire						ad_FCO_p,
	input wire						ad_FCO_n,
	input wire [ADC_CHANEL-1:0]		ad_data_p,
	input wire [ADC_CHANEL-1:0]		ad_data_n,
	output wire 					adc_dco,
	output wire 					adc_fco,
	output wire [ADC_CHANEL-1:0]	adc_data			
    );

	IBUFGDS #
	(
		.DIFF_TERM 		("TRUE"),
		.IBUF_LOW_PWR	("FALSE"),
		.IOSTANDARD		("DEFAULT")
		)
	DCO_inst
	(
		.I 				(ad_DCO_p),
		.IB 			(ad_DCO_n),
		.O 				(adc_dco)
	);

	//IBUFGDS #
	IBUFDS #
	(
		//.DIFF_TERM 		("TRUE"),
		.DIFF_TERM 		("FALSE"),
		.IBUF_LOW_PWR	("FALSE"),
		.IOSTANDARD		("DEFAULT")
		)
	FCO_inst
	(
		.I 				(ad_FCO_p),
		.IB 			(ad_FCO_n),
		.O 				(adc_fco)
	);


	generate
	begin
		genvar 	i;
		for (i = 0; i < ADC_CHANEL; i = i + 1)
		begin : data_diff_to_single
			IBUFDS IBUFDS_data_D2S 
			(
				.O 				(adc_data[i]), 			// Buffer output
				.I 				(ad_data_p[i]), 		// Diff_p buffer input (connect directly to top-level port)
				.IB 			(ad_data_n[i]) 			// Diff_n buffer input (connect directly to top-level port)
			);
		end
	end
	endgenerate
endmodule
