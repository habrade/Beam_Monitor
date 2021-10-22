//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/22 09:08:09
// Design Name: 
// Module Name: header_tail_gen
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

module header_tail_gen (
	input 				clk_10m,    	// Clock
	input 				clk_100m,	//
	input 				reset,  	// Asynchronous reset active low
	input 				resync,		// From software, sync the date and time,
	input [15:0]		data_type,	//
	input [31:0] 		frame_num,
	input [15:0] 		time_high,  // Contains year, months
	input [15:0] 		time_mid,	// date, hours
	input [15:0] 		time_low, 	// minutes, seconds
	input [31:0]		time_usec,  // micro seconds
	input [15:0] 		chip_num,	// The upper 8 bits are the chip end number, and the lower eight bits are the chip start number.
	input [3:0] 		board_num,
	output [127:0] 		header,
	output [127:0] 		tail
);

	reg [31:0] 			evt_size; 		// Default size, bytes
	reg [31:0] 			evt_sub_size; 		// Default size, bytes
	reg [31:0] 			evt_decoding;	// Every 32 bits contains the number of pixels
	reg [31:0] 			evt_ID;			// From software
	reg [31:0] 			evt_seqnr_h; 	// Frame number in header
	reg [31:0] 			evt_seqnr_t; 	// Frame number in tail
	reg [31:0] 			evt_date;		// From software and self-add
	reg [31:0] 			evt_time;		// From software and self-add
	reg [31:0] 			evt_time2;
	reg [31:0] 			run_nr;			// board No. Chip No.
	reg [31:0] 			evt_pad; 		// 

 	reg [11:0]			dec_year;
 	reg [3:0] 			dec_month;
 	reg [4:0] 			dec_date;
 	reg [4:0] 			dec_hour;
 	reg [5:0] 			dec_minute;
 	reg [7:0] 			dec_second;
 	reg [9:0] 			dec_msecond;
 	reg [31:0] 			dec_usecond; // 12 hour = 32'hD693A400 us

 	reg [3:0] 			time_add;

 	always @(posedge clk_100m or posedge reset) begin : proc_
 		if(reset) begin
 			evt_size 		<= 0;
 			evt_decoding	<= 0;
 			evt_ID 			<= 0;
 			evt_seqnr_h 	<= 0;
 			evt_seqnr_t 	<= 0;
 			evt_date 		<= 0;
 			evt_time 		<= 0;
 			evt_time2 		<= 0;
 			run_nr 			<= 0;
 			evt_pad 		<= 0;
 		end else begin
 			evt_size 		<= 32'd166144;
 			evt_sub_size 	<= 32'd166112;
 			evt_decoding 	<= {4'd2,12'd16,16'd0};
 			evt_ID 			<= {16'd0,data_type};
 			evt_seqnr_h 	<= dec_usecond;
 			evt_seqnr_t 	<= frame_num;
 			evt_date 		<= {dec_year,dec_month,dec_date,dec_hour,dec_minute};
 			evt_time 		<= {dec_second,dec_msecond,dec_usecond,time_add};
 			run_nr 			<= {12'd0,board_num,chip_num};
 			evt_pad 		<= 32'd0;
 		end
 	end

 	always @(posedge clk_10m or posedge reset) 
 	begin : proc_time_add
 		if(reset | resync) begin
 			time_add <= 0;
 		end else begin
 			time_add <= time_add + 1;
 			if(time_add == 15'd9) begin
 				time_add <= 0;
 			end
 		end
 	end
 	always @(posedge clk_10m or posedge reset) 
 	begin : proc_timestamp
 		if(reset) begin
 			dec_year 	<= 2020;
 			dec_month	<= 1;
 			dec_date 	<= 1;
 			dec_hour	<= 0;
 			dec_minute 	<= 0;
 			dec_second	<= 0;
 			dec_msecond <= 0;
 			dec_usecond <= 0;
 		end else if(resync) begin
 			dec_year 	<= time_high[15:4];
 			dec_month	<= time_high[3:0];
 			dec_date	<= time_mid[15:8];
 			dec_hour	<= time_mid[7:0];
 			dec_minute 	<= time_low[15:8];
 			dec_second	<= time_low[7:0];
 			dec_msecond <= 0;
 			dec_usecond <= time_usec;
 		end else begin 
 			if(time_add == 15'd9) begin
 				dec_usecond <= dec_usecond + 1;
 			end
 			if((dec_usecond % 1000 == 0) & (dec_usecond > 0)) begin
 				dec_msecond <= dec_msecond + 1;
 				if(dec_usecond == 32'hD693A400) begin
 					dec_usecond <= 0;
 				end
 			//	dec_usecond <= 0;
 			end
 			if(dec_msecond == 12'd1000) begin
 				dec_second 	<= dec_second + 1;
 				dec_msecond	<= 0;
 			end
 			if(dec_second == 8'd60) begin
 				dec_minute	<= dec_minute + 1;
 				dec_second 	<= 0;
 			end
 			if(dec_minute == 8'd60) begin
 				dec_hour	<= dec_hour + 1;
 				dec_minute 	<= 0;
 			end
 			if(dec_hour == 8'd24) begin
 				dec_date	<= dec_date + 1;
 				dec_hour 	<= 0;
 			end
 			case (dec_month)
 				4'd2:begin 
					if(dec_date == 8'd29) begin
 						dec_month	<= dec_month + 1;
 						dec_date 	<= 1;
 					end
 				end
 				4'd1,4'd3,4'd5,4'd7,4'd8,4'd10,4'd12:
 				begin 
 					if(dec_date == 8'd32) begin
 						dec_month	<= dec_month + 1;
 						dec_date 	<= 1;
 					end
 				end
 				4'd4,4'd6,4'd9,4'd11:
 				begin 
 					if(dec_date == 8'd31) begin
 						dec_month	<= dec_month + 1;
 						dec_date 	<= 1;
 					end
 				end
 			endcase
 			if(dec_month == 4'd13) begin
 				dec_year 	<= dec_year + 1;
 				dec_month	<= 1;
 			end
 		end
 	end
 	//511 bits
 	//assign header = {224'd0,evt_pad,run_nr,evt_time,evt_date,evt_seqnr,evt_ID,evt_decoding,evt_size,32'hEB9055AA};
 	/*assign header = {32'hEB9055AA,evt_size,		evt_decoding,evt_ID,evt_seqnr_h,evt_date,evt_time,run_nr,
 						  evt_pad,evt_sub_size, evt_decoding,evt_ID,evt_seqnr_h,evt_date,evt_time,run_nr};
 	//assign tail = {224'd0,evt_pad,run_nr,evt_time,evt_date,evt_seqnr,evt_ID,evt_decoding,evt_size,32'hEB905AA5};
 	assign tail = {32'hEB905AA5,evt_size,	  evt_decoding,evt_ID,evt_seqnr_t,evt_date,evt_time,run_nr,
 						evt_pad,evt_sub_size, evt_decoding,evt_ID,evt_seqnr_t,evt_date,evt_time,run_nr};*/

 	assign header = {32'hEB9055AA,evt_size,		evt_decoding,evt_ID};
 	assign tail = {32'hEB905AA5,evt_size,	  evt_decoding,evt_ID};
endmodule