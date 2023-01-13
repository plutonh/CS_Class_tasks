`timescale 1ns / 1ps
//6.097ns정도 걸림.
module WB(
// control signal
input Ctl_MemtoReg_in, 
input [31:0] LoadData_in, ALUresult_in,

output [31:0] WriteData_out
);

assign WriteData_out = (Ctl_MemtoReg_in)? LoadData_in : ALUresult_in;


endmodule


