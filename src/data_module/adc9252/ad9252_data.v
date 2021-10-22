`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/22 09:06:09
// Design Name: 
// Module Name: ad9252_data
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
module ad9252_data #
(
	parameter 				DATA_DLY_TAPS = 16
	)
	(
	input wire 				ad_dco,    		// Clock dco
	input wire 				ad_dco_fc, 		// Clock fc from dco
	input wire 				reset,  		// Asynchronous reset active low
	input wire 				ad_data,		// ADC serial data in
	input wire 				bit_slip, 
	input wire 				clk_en,
	input wire 				delay_ld,
	input wire 				delay_ce,
	input wire 				delay_inc,
	input wire [4:0]		cntvaluein,
	output wire [13:0]      ad_data_para 	// ADC parallel data out
);

	wire 					shift_wire_1;
	wire 					shift_wire_2;
	wire 					data_ddly;

	//(* IODELAY_GROUP = "dco_delay" *)
	IDELAYE2 #
	(
		.IS_IDATAIN_INVERTED    (0),
		.IS_C_INVERTED          (0),
		.IS_DATAIN_INVERTED     (0),    
		.CINVCTRL_SEL           ("FALSE"),              // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC              ("IDATAIN"),            // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE  ("FALSE"),              // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE            ("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		.IDELAY_VALUE           (DATA_DLY_TAPS),          // Input delay tap setting (0-31)
		.PIPE_SEL               ("FALSE"),              // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY       (200.0),                // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN         ("DATA")               // DATA, CLOCK input signal
	 )
	IDELAYE2_data
	(
		.DATAIN                 (0),		            // in
		.IDATAIN                (ad_data),		        // in
		.CE                     (delay_ce),				// in
		.INC                    (delay_inc),					// in
		.C                      (ad_dco_fc),			// in
		.LD                     (delay_ld),				// in
		.LDPIPEEN               (0),		            // in
		.REGRST                 (reset),				// in
		.DATAOUT                (data_ddly),			// out
		.CINVCTRL               (0),		            // in
		.CNTVALUEOUT            (),		                // out [4:0]
		.CNTVALUEIN             (cntvaluein)		        // in [4:0]
	);


	ISERDESE2 #(
	  	.DATA_RATE				("DDR"),           	// DDR, SDR
	  	.DATA_WIDTH				(14),              	// Parallel data width (2-8,10,14)
	  	.DYN_CLKDIV_INV_EN		("FALSE"), 			// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
	  	.DYN_CLK_INV_EN 		("FALSE"),    		// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
	  	.INIT_Q1				(1'b0),
	  	.INIT_Q2				(1'b0),
	  	.INIT_Q3				(1'b0),
	  	.INIT_Q4				(1'b0),
	  	.INTERFACE_TYPE			("NETWORKING"),		// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
	  	.IOBDELAY				("IFD"),           // NONE, BOTH, IBUF, IFD
	  	.NUM_CE					(2),                // Number of clock enables (1,2)
	  	.OFB_USED 				("FALSE"),          // Select OFB path (FALSE, TRUE)
	  	.SERDES_MODE 			("MASTER"),      	// MASTER, SLAVE
	  	.SRVAL_Q1				(1'b0),
	  	.SRVAL_Q2				(1'b0),
	  	.SRVAL_Q3				(1'b0),
	  	.SRVAL_Q4				(1'b0) 
   )
   ISERDESE2_data_Master (
	  	.O						(),                  // 1-bit output: Combinatorial output
	  	.Q1						(ad_data_para[0]),     // Q1 - Q8: 1-bit (each) output: Registered data outputs
	  	.Q2						(ad_data_para[1]),
	  	.Q3						(ad_data_para[2]),
	  	.Q4						(ad_data_para[3]),
	  	.Q5						(ad_data_para[4]),
	  	.Q6						(ad_data_para[5]),
	  	.Q7						(ad_data_para[6]),
	  	.Q8						(ad_data_para[7]),
	  	.SHIFTOUT1				(shift_wire_1),
	  	.SHIFTOUT2				(shift_wire_2),
	  	.BITSLIP				(bit_slip),           
	  	.CE1					(clk_en),
	  	.CE2					(clk_en),
	  	.CLKDIVP				(1'b0),             // 1-bit input: TBD
	  	.CLK					(ad_dco),           // 1-bit input: High-speed clock
	  	.CLKB					(~ad_dco),          // 1-bit input: High-speed secondary clock
	  	.CLKDIV					(ad_dco_fc),        // 1-bit input: Divided clock
	  	.OCLK 					(1'b0),             // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
	  	.DYNCLKDIVSEL			(1'b0),         	// 1-bit input: Dynamic CLKDIV inversion
	  	.DYNCLKSEL				(1'b0),            	// 1-bit input: Dynamic CLK/CLKB inversion
	  	.D 						(1'b0),          	// 1-bit input: Data input
	  	.DDLY 					(data_ddly),        // 1-bit input: Serial data from IDELAYE2
	  	.OFB 					(1'b0),             // 1-bit input: Data feedback from OSERDESE2
	  	.OCLKB 					(1'b0),             // 1-bit input: High speed negative edge output clock
	  	.RST 					(reset),         	// 1-bit input: Active high asynchronous reset
	  	.SHIFTIN1 				(1'b0),
	  	.SHIFTIN2 				(1'b0) 
   );

   ISERDESE2 #(
	  	.DATA_RATE				("DDR"),           	// DDR, SDR
	  	.DATA_WIDTH				(14),              	// Parallel data width (2-8,10,14)
	  	.DYN_CLKDIV_INV_EN		("FALSE"), 			// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
	  	.DYN_CLK_INV_EN 		("FALSE"),    		// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
	  	.INIT_Q1				(1'b0),
	  	.INIT_Q2				(1'b0),
	  	.INIT_Q3				(1'b0),
	  	.INIT_Q4				(1'b0),
	  	.INTERFACE_TYPE			("NETWORKING"),		// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
	  	.IOBDELAY				("NONE"),           // NONE, BOTH, IBUF, IFD
	  	.NUM_CE					(2),                // Number of clock enables (1,2)
	  	.OFB_USED 				("FALSE"),          // Select OFB path (FALSE, TRUE)
	  	.SERDES_MODE 			("SLAVE"),      	// MASTER, SLAVE
	  	.SRVAL_Q1				(1'b0),
	  	.SRVAL_Q2				(1'b0),
	  	.SRVAL_Q3				(1'b0),
	  	.SRVAL_Q4				(1'b0) 
   )
   ISERDESE2_data_Slave (
	  	.O						(),                 // 1-bit output: Combinatorial output
	  	.Q1						(),         		// Q1 - Q8: 1-bit (each) output: Registered data outputs
	  	.Q2						(),
	  	.Q3						(ad_data_para[8]),
	  	.Q4						(ad_data_para[9]),
	  	.Q5						(ad_data_para[10]),
	  	.Q6						(ad_data_para[11]),
	  	.Q7						(ad_data_para[12]),
	  	.Q8						(ad_data_para[13]),
	  	.SHIFTOUT1				(),
	  	.SHIFTOUT2				(),
	  	.BITSLIP				(bit_slip),           
	  	.CE1					(clk_en),
	  	.CE2					(clk_en),
	  	.CLKDIVP				(1'b0),             // 1-bit input: TBD
	  	.CLK					(ad_dco),           // 1-bit input: High-speed clock
	  	.CLKB					(~ad_dco),          // 1-bit input: High-speed secondary clock
	  	.CLKDIV					(ad_dco_fc),        // 1-bit input: Divided clock
	  	.OCLK 					(1'b0),             // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
	  	.DYNCLKDIVSEL			(1'b0),         	// 1-bit input: Dynamic CLKDIV inversion
	  	.DYNCLKSEL				(1'b0),            	// 1-bit input: Dynamic CLK/CLKB inversion
	  	.D 						(1'b0),          	// 1-bit input: Data input
	  	.DDLY 					(1'b0),             // 1-bit input: Serial data from IDELAYE2
	  	.OFB 					(1'b0),             // 1-bit input: Data feedback from OSERDESE2
	  	.OCLKB 					(1'b0),             // 1-bit input: High speed negative edge output clock
	  	.RST 					(reset),         	// 1-bit input: Active high asynchronous reset
	  	.SHIFTIN1 				(shift_wire_1),
	  	.SHIFTIN2 				(shift_wire_2) 
   );

endmodule