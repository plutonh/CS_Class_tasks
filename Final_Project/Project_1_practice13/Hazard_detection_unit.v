`timescale 1ns / 1ps


//엄밀히 따지자면 명령어 종류에 따라 rs1, rs2가 쓰이는지가 달라지니 그것부터 판별해야 할 듯.
module Hazard_detection_unit(
	input exe_Ctl_MemRead_in,	//load인지 판별
	input [4:0] Rd_in,
	input [9:0] instruction_in,
	output stall_out
    );
	 
	wire [4:0] Rs1_in = instruction_in[4:0];
	wire [4:0] Rs2_in = instruction_in[9:5];
	 
	assign stall_out = ( exe_Ctl_MemRead_in && (Rd_in == Rs1_in || Rd_in == Rs2_in) ) ? 1:0;


endmodule
