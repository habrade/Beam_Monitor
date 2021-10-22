// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Tue Jan 19 15:24:22 2021
// Host        : sdong-ubuntu running 64-bit Ubuntu 20.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/sdong/work/JadePix3/firmware/ipcores/fifo_generator_0/fifo_generator_0_stub.v
// Design      : fifo_generator_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module fifo_generator_0(clk, srst, din, wr_en, rd_en, dout, full, empty, valid, 
  data_count, prog_full)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[2:0],wr_en,rd_en,dout[2:0],full,empty,valid,data_count[16:0],prog_full" */;
  input clk;
  input srst;
  input [2:0]din;
  input wr_en;
  input rd_en;
  output [2:0]dout;
  output full;
  output empty;
  output valid;
  output [16:0]data_count;
  output prog_full;
endmodule
