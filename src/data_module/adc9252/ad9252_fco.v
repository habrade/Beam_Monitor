`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/21 09:06:09
// Design Name: 
// Module Name: ad9252_fco
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

module ad9252_fco #
(
	parameter 				FCO_DELAY_TAPS = 16
	)
	(
	input wire 				adc_fco,    		// Clock
	input wire 				reset,  			// Asynchronous reset active high
	input wire 				ad_dco_fc,
	input wire 				ad_dco,
	input wire 				bit_slip,
	input wire 				clk_en,
	output wire [13:0] 		fco_pattern
);
	
	
	wire 					shift_wire_1;
	wire 					shift_wire_2;
	wire 					fco_ddly;
	
	IDELAYE2 #
	(
		.IS_IDATAIN_INVERTED    (0),
		.IS_C_INVERTED          (0),
		.IS_DATAIN_INVERTED     (0),    
		.CINVCTRL_SEL           ("FALSE"),              // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC              ("IDATAIN"),            // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE  ("FALSE"),              // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE            ("VARIABLE"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		//.IDELAY_TYPE            ("VAR_LOAD"),
		.IDELAY_VALUE           (FCO_DELAY_TAPS),       // Input delay tap setting (0-31)
		.PIPE_SEL               ("FALSE"),              // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY       (200.0),                // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN         ("CLOCK")               // DATA, CLOCK input signal
	 )
	IDELAYE2_fco
	(
		.DATAIN                 (0),		            // in
		.IDATAIN                (adc_fco),		        // in
		.CE                     (0),					// in
		.INC                    (0),					// in
		.C                      (ad_dco_fc),			// in
		.LD                     (reset),				// in
		.LDPIPEEN               (0),		            // in
		.REGRST                 (reset),				// in
		.DATAOUT                (fco_ddly),			// out
		.CINVCTRL               (0),		            // in
		.CNTVALUEOUT            (),		                // out [4:0]
		.CNTVALUEIN             (5'd0)		        // in [4:0]
	);

	ISERDESE2 #(
	  .DATA_RATE			("DDR"),           	// DDR, SDR
	  .DATA_WIDTH			(14),              	// Parallel data width (2-8,10,14)
	  .DYN_CLKDIV_INV_EN	("FALSE"), 			// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
	  .DYN_CLK_INV_EN 		("FALSE"),    		// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
	  .INIT_Q1				(1'b0),
	  .INIT_Q2				(1'b0),
	  .INIT_Q3				(1'b0),
	  .INIT_Q4				(1'b0),
	  .INTERFACE_TYPE		("NETWORKING"),		// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
	  .IOBDELAY				("IFD"),           // NONE, BOTH, IBUF, IFD
	  .NUM_CE				(2),                // Number of clock enables (1,2)
	  .OFB_USED 			("FALSE"),          // Select OFB path (FALSE, TRUE)
	  .SERDES_MODE 			("MASTER"),      	// MASTER, SLAVE
	  .SRVAL_Q1				(1'b0),
	  .SRVAL_Q2				(1'b0),
	  .SRVAL_Q3				(1'b0),
	  .SRVAL_Q4				(1'b0) 
   )
   ISERDESE2_fco_Master (
	  .O					(),                  // 1-bit output: Combinatorial output
	  .Q1					(fco_pattern[0]),    // Q1 - Q8: 1-bit (each) output: Registered data outputs
	  .Q2					(fco_pattern[1]),
	  .Q3					(fco_pattern[2]),
	  .Q4					(fco_pattern[3]),
	  .Q5					(fco_pattern[4]),
	  .Q6					(fco_pattern[5]),
	  .Q7					(fco_pattern[6]),
	  .Q8					(fco_pattern[7]),
	  .SHIFTOUT1			(shift_wire_1),
	  .SHIFTOUT2			(shift_wire_2),
	  .BITSLIP				(bit_slip),           
	  .CE1					(clk_en),
	  .CE2					(clk_en),
	  .CLKDIVP				(1'b0),             // 1-bit input: TBD
	  .CLK					(ad_dco),           // 1-bit input: High-speed clock
	  .CLKB					(~ad_dco),          // 1-bit input: High-speed secondary clock
	  .CLKDIV				(ad_dco_fc),        // 1-bit input: Divided clock
	  .OCLK 				(1'b0),             // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
	  .DYNCLKDIVSEL			(1'b0),         	// 1-bit input: Dynamic CLKDIV inversion
	  .DYNCLKSEL			(1'b0),             // 1-bit input: Dynamic CLK/CLKB inversion
	  .D 					(1'b0),          	// 1-bit input: Data input
	  .DDLY 				(fco_ddly),         // 1-bit input: Serial data from IDELAYE2
	//  .DDLY 				(1'b0),
	  .OFB 					(1'b0),             // 1-bit input: Data feedback from OSERDESE2
	  .OCLKB 				(1'b0),             // 1-bit input: High speed negative edge output clock
	  .RST 					(reset),         	// 1-bit input: Active high asynchronous reset
	  .SHIFTIN1 			(1'b0),
	  .SHIFTIN2 			(1'b0) 
   );

   ISERDESE2 #(
	  .DATA_RATE			("DDR"),           	// DDR, SDR
	  .DATA_WIDTH			(14),              	// Parallel data width (2-8,10,14)
	  .DYN_CLKDIV_INV_EN	("FALSE"), 			// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
	  .DYN_CLK_INV_EN 		("FALSE"),    		// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
	  .INIT_Q1				(1'b0),
	  .INIT_Q2				(1'b0),
	  .INIT_Q3				(1'b0),
	  .INIT_Q4				(1'b0),
	  .INTERFACE_TYPE		("NETWORKING"),		// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
	  .IOBDELAY				("NONE"),           // NONE, BOTH, IBUF, IFD
	  .NUM_CE				(2),                // Number of clock enables (1,2)
	  .OFB_USED 			("FALSE"),          // Select OFB path (FALSE, TRUE)
	  .SERDES_MODE 			("SLAVE"),      	// MASTER, SLAVE
	  .SRVAL_Q1				(1'b0),
	  .SRVAL_Q2				(1'b0),
	  .SRVAL_Q3				(1'b0),
	  .SRVAL_Q4				(1'b0) 
   )
   ISERDESE2_fco_Slave (
	  .O					(),                 // 1-bit output: Combinatorial output
	  .Q1					(),         		// Q1 - Q8: 1-bit (each) output: Registered data outputs
	  .Q2					(),
	  .Q3					(fco_pattern[8]),
	  .Q4					(fco_pattern[9]),
	  .Q5					(fco_pattern[10]),
	  .Q6					(fco_pattern[11]),
	  .Q7					(fco_pattern[12]),
	  .Q8					(fco_pattern[13]),
	  .SHIFTOUT1			(),
	  .SHIFTOUT2			(),
	  .BITSLIP				(bit_slip),           
	  .CE1					(clk_en),
	  .CE2					(clk_en),
	  .CLKDIVP				(1'b0),             // 1-bit input: TBD
	  .CLK					(ad_dco),           // 1-bit input: High-speed clock
	  .CLKB					(~ad_dco),          // 1-bit input: High-speed secondary clock
	  .CLKDIV				(ad_dco_fc),        // 1-bit input: Divided clock
	  .OCLK 				(1'b0),             // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
	  .DYNCLKDIVSEL			(1'b0),         	// 1-bit input: Dynamic CLKDIV inversion
	  .DYNCLKSEL			(1'b0),            	// 1-bit input: Dynamic CLK/CLKB inversion
	  .D 					(1'b0),             // 1-bit input: Data input
	  .DDLY 				(1'b0),             // 1-bit input: Serial data from IDELAYE2
	  .OFB 					(1'b0),             // 1-bit input: Data feedback from OSERDESE2
	  .OCLKB 				(1'b0),             // 1-bit input: High speed negative edge output clock
	  .RST 					(reset),         	// 1-bit input: Active high asynchronous reset
	  .SHIFTIN1 			(shift_wire_1),
	  .SHIFTIN2 			(shift_wire_2) 
   );

   

endmodule