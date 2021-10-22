//--------------------------------------------------------------------------------------------
// ?? 5? 17 2019 20:56:46
//
//      Input file      : 
//      Component name  : adc9252_dco
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//---------------------------------------------------------------------------------------------
//
//---------------------------------------------------------------------------------------------
// Entity pin description
//---------------------------------------------------------------------------------------------
module ad9252_dco#
	(
		parameter          C_StatTaps = 16
		)
	(
	BitClk,
	BitClkRst,
	BitClkEna,
	BitClkReSync,
	BitClk_MonClkOut,
	BitClk_MonClkIn,
	BitClk_RefClkOut,
	BitClk_RefClkIn,
	BitClkAlignWarn,
	BitClkInvrtd,
	BitClkPattern,
	BitClkFsm,
	BitClkDone
);

	input              BitClk;
	input              BitClkRst;
	input              BitClkEna;
	input              BitClkReSync;
	output             BitClk_MonClkOut;		// CLK output
	input              BitClk_MonClkIn;			// ISERDES.CLK input
	output             BitClk_RefClkOut;		// CLKDIV & logic output
	input              BitClk_RefClkIn;			// CLKDIV & logic input
	output             BitClkAlignWarn;
	output             BitClkInvrtd;
	output             BitClkDone;
	output [7:0] 	   BitClkPattern;
	output [3:0] 	   BitClkFsm;

	// Constants
	parameter          Low 			= 1'b0;
	parameter [4:0]    LowNibble 	= 5'b00000;
	parameter          High 		= 1'b1;
	// Signals
	wire               IntBitClkRst;
	wire			   BitClkData;				// For ISERDESE2 "D" port
	//-------- ISRDS signals ------------------
	reg                IntClkCtrlDlyCe;
	reg                IntClkCtrlDlyInc;
	wire               IntClkCtrlDlyRst;
	
	wire               IntBitClk_Ddly;
	wire               IntBitClk;
	wire [7:0]         IntClkCtrlOut;
	//-------- Controller signals -------------
	wire               IntCal;
	wire               IntVal;
	reg [1:0]          IntCalVal;
	reg [2:0]          IntProceedCnt;
	wire               IntproceedCntTc;
	reg                IntproceedCntTc_d;
	reg                IntProceed;
	reg                IntProceedDone;
	
	parameter [3:0]    StateType_Idle 	= 0,
					   StateType_A 		= 1,
					   StateType_B 		= 2,
					   StateType_C 		= 3,
					   StateType_D 		= 4,
					   StateType_E 		= 5,
					   StateType_F 		= 6,
					   StateType_G 		= 7,
					   StateType_G1 	= 8,
					   StateType_H 		= 9,
					   StateType_K 		= 10,
					   StateType_K1 	= 11,
					   StateType_K2 	= 12,
					   StateType_IdlyIncDec = 13,
					   StateType_Done 	= 14;
	reg [3:0]          State;
	reg [3:0]          ReturnState;
	
	reg                PassedSubState;
	reg [3:0]          IntNumIncDecIdly;
	reg [1:0]          IntAction;
	reg                IntClkCtrlDone;
	reg                IntClkCtrlAlgnWrn;
	reg                IntClkCtrlInvrtd;
	reg                IntTurnAroundBit;
	reg [1:0]          IntCalValReg;
	reg [3:0]          IntTimeOutCnt;
	reg [3:0]          IntStepCnt;
	
	//---------------------------------------------------------------------------------------------
	// Bit clock capture ISERDES Master-Slave combination
	//---------------------------------------------------------------------------------------------
//	(* IODELAY_GROUP = "dco_delay" *)
	IDELAYE2 #
	(
		.IS_IDATAIN_INVERTED    (1),
		.IS_C_INVERTED          (0),
		.IS_DATAIN_INVERTED     (0),    
		.CINVCTRL_SEL           ("FALSE"),              // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC              ("IDATAIN"),            // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE  ("FALSE"),              // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE            ("VARIABLE"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		.IDELAY_VALUE           (C_StatTaps),           // Input delay tap setting (0-31)
		.PIPE_SEL               ("FALSE"),              // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY       (200.0),                // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN         ("CLOCK")               // DATA, CLOCK input signal
	 )
	IDELAYE2_dco
	(
		.DATAIN                 (Low),		            // in
		.IDATAIN                (BitClk),		        // in
		.CE                     (IntClkCtrlDlyCe),		// in
		.INC                    (IntClkCtrlDlyInc),		// in
		.C                      (BitClk_RefClkIn),		// in
		.LD                     (IntClkCtrlDlyRst),		// in
		.LDPIPEEN               (Low),		            // in
		.REGRST                 (IntClkCtrlDlyRst),		// in
		.DATAOUT                (IntBitClk_Ddly),		// out
		.CINVCTRL               (Low),		            // in
		.CNTVALUEOUT            (),		                // out [4:0]
		.CNTVALUEIN             (LowNibble)		        // in [4:0]
	);

	assign IntClkCtrlDlyRst = BitClkRst;
	//
	
	ISERDESE2 #
	(
		.DATA_RATE				("SDR"),           		// DDR, SDR
		.DATA_WIDTH				(8),              		// Parallel data width (2-8,10,14)
		.DYN_CLKDIV_INV_EN		("FALSE"), 				// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
		.DYN_CLK_INV_EN 		("FALSE"),    			// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
		.INIT_Q1				(1'b0),
		.INIT_Q2				(1'b0),
		.INIT_Q3				(1'b0),
		.INIT_Q4				(1'b0),
		.INTERFACE_TYPE 		("NETWORKING"),			// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
		.IOBDELAY				("IBUF"),           	// NONE, BOTH, IBUF, IFD
		.NUM_CE					(1),                  	// Number of clock enables (1,2)
		.OFB_USED				("FALSE"),          	// Select OFB path (FALSE, TRUE)
		.SERDES_MODE			("MASTER"),      		// MASTER, SLAVE
		.SRVAL_Q1				(1'b0),
		.SRVAL_Q2				(1'b0),
		.SRVAL_Q3				(1'b0),
		.SRVAL_Q4				(1'b0)
	) 
	ISERDESE2_dco
	(		// OCLK clock input is NOT inverted
		.D						(BitClk),				// in	Clock from clock input IBUFDS
		.DDLY					(IntBitClk_Ddly),		// in
		.DYNCLKDIVSEL			(Low),					// in
		.DYNCLKSEL				(Low),					// in
		.OFB					(Low),					// in
		.BITSLIP				(Low),					// in
		.CE1					(BitClkEna),			// in
		.CE2					(Low),					// in
		.RST					(IntBitClkRst),			// in
		.CLK					(BitClk_MonClkIn),		// in
		.CLKB					(Low),					// in
		.CLKDIV					(BitClk_RefClkIn),		// in
		.CLKDIVP				(Low),					// in
		.OCLK					(Low),					// in
		.OCLKB					(Low),					// in
		.SHIFTIN1				(Low),					// in
		.SHIFTIN2				(Low),					// in
		.O						(IntBitClk),			// out
		.Q1						(IntClkCtrlOut[0]),		// out
		.Q2						(IntClkCtrlOut[1]),		// out
		.Q3						(IntClkCtrlOut[2]),		// out
		.Q4						(IntClkCtrlOut[3]),		// out
		.Q5						(IntClkCtrlOut[4]),		// out
		.Q6						(IntClkCtrlOut[5]),		// out
		.Q7						(IntClkCtrlOut[6]),		// out
		.Q8						(IntClkCtrlOut[7]),		// out
		.SHIFTOUT1				(),						// out
		.SHIFTOUT2				()						// out
	);
	// Input from ISERDES.O	  -- Output and CLK for all ISERDES

	BUFIO BUFIO_dco 
	(
		.O						(BitClk_MonClkOut), 	// 1-bit output: Clock output (connect to I/O clock loads).
		.I						(IntBitClk) 			// 1-bit input: Clock input (connect to an IBUF or BUFMR).
	);
	BUFR #
	(
		.BUFR_DIVIDE			("7"), 					// Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
		.SIM_DEVICE				("7SERIES") 			// Must be set to "7SERIES"
	)
	BUFR_dco_fc
	(
		.O						(BitClk_RefClkOut), 	// 1-bit output: Clock output port
		.CE						(High), 				// 1-bit input: Active high, clock enable (Divided modes only)
		.CLR					(Low), 					// 1-bit input: Active high, asynchronous clear (Divided modes only)
		.I 						(IntBitClk) 			// 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
	);

	//---------------------------------------------------------------------------------------------
	// Bit clock re-synchronizer
	//---------------------------------------------------------------------------------------------
	assign IntBitClkRst = BitClkRst | BitClkReSync;
	//---------------------------------------------------------------------------------------------
	// Bit clock controller for clock alignment input.
	//---------------------------------------------------------------------------------------------
	// This input section makes sure 64 bits are captured before action is taken to pass to
	// the state machine for evaluation.
	// 8 samples of the Bit Clock are taken by the ISERDES and then transferred to the parallel
	// FPGA world. The Proceed counter needs 8 reference clock rising edges before terminal count.
	// The Proceed counter terminal count then loads the 2 control bits (made from sampled clock)
	// into an intermediate register (IntCalVal).
	//
	// IntCal = '1' when all outputs of the ISERDES are '1 else it's '0'.
	// IntVal = '1' when all outputs are '0' or '1'.
	//
	assign IntCal 			= 	IntClkCtrlOut[7] & IntClkCtrlOut[6] & 
								IntClkCtrlOut[5] & IntClkCtrlOut[4] & 
								IntClkCtrlOut[3] & IntClkCtrlOut[2] & 
								IntClkCtrlOut[1] & IntClkCtrlOut[0];
	assign IntVal 			= ((IntClkCtrlOut == 8'b11111111 | 
								IntClkCtrlOut == 8'b00000000)) ? 1'b1 : 1'b0;
	assign IntproceedCntTc 	= ((IntProceedCnt == 3'b110)) ? 1'b1 : 1'b0;
	assign BitClkAlignWarn 	= IntClkCtrlAlgnWrn;
	assign BitClkInvrtd 	= IntClkCtrlInvrtd;
	assign BitClkDone 		= IntClkCtrlDone;
	assign BitClkPattern	= IntClkCtrlOut;
	assign BitClkFsm 		= State;
	//
	
	always @(posedge IntBitClkRst or posedge BitClk_RefClkIn)
	begin: AdcClock_Proceed_PROCESS
		if (IntBitClkRst == 1'b1) begin
			IntProceedCnt 		<= {3{1'b0}};
			IntproceedCntTc_d 	<= 1'b0;
			IntCalVal 			<= {2{1'b0}};
			IntProceed 			<= 1'b0;
		end else  begin
			if (BitClkEna == 1'b1 & IntClkCtrlDone == 1'b0) begin
				IntProceedCnt 		<= IntProceedCnt + 1;
				IntproceedCntTc_d 	<= IntproceedCntTc;
				if (IntproceedCntTc_d == 1'b1)
					IntCalVal 	<= {IntCal, IntVal};
				if (IntproceedCntTc_d == 1'b1)
					IntProceed 	<= 1'b1;
				else if (IntProceedDone == 1'b1)
					IntProceed 	<= 1'b0;
			end 
		end 
	end
	
	always @(posedge BitClk_RefClkIn or posedge IntBitClkRst)
	begin: AdcClock_State_PROCESS
		if (IntBitClkRst == 1'b1) begin
			State 				<= StateType_Idle;
			ReturnState 		<= StateType_Idle;
			PassedSubState 		<= 1'b0;
			IntNumIncDecIdly 	<= 4'b0000;		// Max. 16
			IntAction 			<= 2'b00;
			IntClkCtrlDlyInc 	<= 1'b1;
			IntClkCtrlDlyCe 	<= 1'b0;
			IntClkCtrlDone 		<= 1'b0;
			IntClkCtrlAlgnWrn 	<= 1'b0;
			IntClkCtrlInvrtd 	<= 1'b0;
			IntTurnAroundBit 	<= 1'b0;
			IntProceedDone 		<= 1'b0;
			IntClkCtrlDone 		<= 1'b0;
			IntCalValReg 		<= {2{1'b0}};		// 2-bit
			IntTimeOutCnt 		<= {4{1'b0}};		// 4-bit
			IntStepCnt 			<= {4{1'b0}};		// 4-bit (16)
		end else  begin
			if (BitClkEna == 1'b1 & IntClkCtrlDone == 1'b0)
				case (State)
					StateType_Idle :
						begin
							IntProceedDone 	<= 1'b0;
							PassedSubState 	<= 1'b0;
							IntStepCnt 		<= {4{1'b0}};
							case ({IntAction[1:0], IntCalVal[1:0], IntProceed})
								5'b00001 :
									State <= StateType_A;
								5'b01001 :
									State <= StateType_B;
								5'b10001 :
									State <= StateType_B;
								5'b11001 :
									State <= StateType_B;
								5'b01111 :
									State <= StateType_C;
								5'b01101 :
									State <= StateType_D;
								5'b01011 :
									State <= StateType_D;
								5'b00011 :
									State <= StateType_E;
								5'b00101 :
									State <= StateType_E;
								5'b00111 :
									State <= StateType_E;
								5'b10011 :
									State <= StateType_F;
								5'b11011 :
									State <= StateType_F;
								5'b10101 :
									State <= StateType_F;
								5'b11101 :
									State <= StateType_F;
								5'b10111 :
									State <= StateType_F;
								5'b11111 :
									State <= StateType_F;
								default :
									State <= StateType_Idle;
							endcase
						end
					// First time and sampling in jitter or cross area.
					StateType_A :		
						begin
							IntAction 			<= 2'b01;					// Set the action bits and go to next step.
							State 				<= StateType_B;
						end
					// Input is sampled in jitter or clock cross area.
					StateType_B :		
						if (PassedSubState == 1'b1) begin
							PassedSubState 		<= 1'b0;					// Clear the pass through the substate bit.
							IntProceedDone 		<= 1'b1;					// Reset the proceed bit.
							State 				<= StateType_Idle;			// Return for a new sample of the input.
						end else if (IntTimeOutCnt == 4'b1111) begin		// When arriving here something is wrong.
							IntTimeOutCnt 		<= 4'b0000;					// Reset the counter.
							IntAction 			<= 2'b00;					// reset the action bits.
							IntClkCtrlAlgnWrn 	<= 1'b1;					// Raise a FLAG.
							IntProceedDone 		<= 1'b1;					// Reset the proceed bit.
							State 				<= StateType_Idle;			// Retry, return for new sample of input.
						end 
						else begin
							IntTimeOutCnt 		<= IntTimeOutCnt + 1;
							IntNumIncDecIdly 	<= 4'b0010;					// Number increments or decrements to do.
							ReturnState 		<= State;					// This state is the state to return too.
							IntProceedDone 		<= 1'b1;					// Reset the proceed bit.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment.
							State 				<= StateType_IdlyIncDec;	// Jump to Increment/decrement sub-state.
						end
					// After first sample, jitter or cross, is now high.
					StateType_C :		
						begin
							IntNumIncDecIdly 	<= 4'b0010;					// Number increments or decrements to do.
							ReturnState 		<= StateType_Done;			// This state is the state to return too.
							IntClkCtrlDlyInc 	<= 1'b0;					// Set for decrement.
							State 				<= StateType_IdlyIncDec;
						end
					// Same as C but with indication of 180-deg shift.
					StateType_D :		
						begin
							IntClkCtrlInvrtd 	<= 1'b1;
							State 				<= StateType_C;
						end
					// First saple with valid data.	
					StateType_E :		
						begin
							IntCalValReg 		<= IntCalVal;				// Register the sampled value
							IntAction 			<= 2'b10;
							IntProceedDone 		<= 1'b1;					// Reset the proceed bit.
							IntNumIncDecIdly 	<= 4'b0001;					// Number increments or decrements to do.
							ReturnState 		<= StateType_Idle;			// When increment is done return sampling.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment
							State 				<= StateType_IdlyIncDec;	// Jump to Increment/decrement sub-state.
						end
					// Next samples with valid data.
					StateType_F :			
						if (IntCalVal != IntCalValReg)
							State <= StateType_G;							// The new CalVal value is different from the first.
						else
							if (IntStepCnt == 4'b1111) begin				// Step counter at the end, 15
								if (IntTurnAroundBit == 1'b0)
									State 		<= StateType_H;				// No edge found and first time here.
								else if (IntCalValReg == 2'b11)
									State 		<= StateType_K;				// A turnaround already happend.
								else
									// No edge is found (large 1/2 period).
									State 		<= StateType_K1;			// Move the clock edge to near the correct
							end else begin
								IntStepCnt 		<= IntStepCnt + 1;
								IntNumIncDecIdly <= 4'b0001;				// Number increments or decrements to do.
								IntProceedDone 	<= 1'b1;					// Reset the proceed bit.
								ReturnState 	<= StateType_Idle;			// When increment is done return sampling.
								IntClkCtrlDlyInc <= 1'b1;					// Set for increment
								State 			<= StateType_IdlyIncDec;	// Jump to Increment/decrement sub-state.
							end
					StateType_G :
						if (IntCalValReg != 2'b01) begin
							IntClkCtrlInvrtd 	<= 1'b1;
							State 				<= StateType_G1;
						end else
							State 				<= StateType_G1;
					StateType_G1 :
						if (IntTimeOutCnt == 2'b00)
							State <= StateType_Done;
						else begin
							IntNumIncDecIdly 	<= 4'b0010;					// Number increments or decrements to do.
							ReturnState 		<= StateType_Done;			// After decrement it's finished.
							IntClkCtrlDlyInc 	<= 1'b0;					// Set for decrement
							State 				<= StateType_IdlyIncDec;	// Jump to the Increment/decrement sub-state.
						end
					StateType_H :
						begin
							IntTurnAroundBit 	<= 1'b1;					// Indicate that the Idelay jumps to 0.
							IntStepCnt 			<= IntStepCnt + 1;			// Set all registers to zero.
							IntAction 			<= 2'b00;					// Take one step, let the counter flow over
							IntCalValReg 		<= 2'b00;					// The idelay turn over to 0.
							IntTimeOutCnt 		<= 4'b0000;					// Start sampling from scratch.
							IntNumIncDecIdly 	<= 4'b0001;					// Number increments or decrements to do.
							IntProceedDone 		<= 1'b1;					// Reset the proceed bit.
							ReturnState 		<= StateType_Idle;			// After increment go sampling for new.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment.
							State 				<= StateType_IdlyIncDec;	// Jump to the Increment/decrement sub-state.
						end
					StateType_K :
						begin
							IntNumIncDecIdly 	<= 4'b1111;					// Number increments or decrements to do.
							ReturnState 		<= StateType_K2;			// After increment it is done.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment.
							State 				<= StateType_IdlyIncDec;	// Jump to the Increment/decrement sub-state.
						end
					StateType_K1 :
						begin
							IntNumIncDecIdly 	<= 4'b1110;					// Number increments or decrements to do.
							ReturnState 		<= StateType_K2;			// After increment it is done.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment.
							State 				<= StateType_IdlyIncDec;	// Jump to the Increment/decrement sub-state.
						end
					StateType_K2 :
						begin
							IntNumIncDecIdly 	<= 4'b0001;					// Number increments or decrements to do.
							ReturnState 		<= StateType_Done;			// After increment it is done.
							IntClkCtrlDlyInc 	<= 1'b1;					// Set for increment.
							State 				<= StateType_IdlyIncDec;	// Jump to the Increment/decrement sub-state.
						end
					// Increment or decrement by enable.
					StateType_IdlyIncDec :									
						if (IntNumIncDecIdly != 4'b0000) begin				// Check number of tap jumps
							IntNumIncDecIdly 	<= IntNumIncDecIdly - 1;	// If not 0 jump and decrement.
							IntClkCtrlDlyCe 	<= 1'b1;					// Do the jump. enable it.
						end else begin
							IntClkCtrlDlyCe 	<= 1'b0;					// when it is enabled, disbale it
							PassedSubState 		<= 1'b1;					// Set a check bit "I've been here and passed".
							State 				<= ReturnState;				// Return to origin.
						end
					// Alignment done.	
					StateType_Done :										
						IntClkCtrlDone 			<= 1'b1;					// Alignment is done.
					default :
							State 				<= StateType_Idle;
				endcase
		end 
	end
	
endmodule
