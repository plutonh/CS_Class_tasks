`timescale 1ns / 1ps

module Forwarding_unit(
	input MEM_Ctl_RegWrite_in, WB_Ctl_RegWrite_in,
	input [4:0] Rs1_in, Rs2_in, EX_MEM_Rd_in, MEM_WB_Rd_in,
	output [1:0] ForwardA_out, ForwardB_out
   );
	 
	assign ForwardA_out = (MEM_Ctl_RegWrite_in && (EX_MEM_Rd_in == Rs1_in) ) ? 2'b10:
								  (WB_Ctl_RegWrite_in && (MEM_WB_Rd_in == Rs1_in) ) ? 2'b01: 2'b00;
								
	assign ForwardB_out = (MEM_Ctl_RegWrite_in && (EX_MEM_Rd_in == Rs2_in) ) ? 2'b10:
								  (WB_Ctl_RegWrite_in && (MEM_WB_Rd_in == Rs2_in) ) ? 2'b01: 2'b00;
endmodule
