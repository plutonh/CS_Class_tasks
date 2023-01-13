`timescale 1ns / 1ps

module WB(
// control signal
input Ctl_RegWrite_in, Ctl_MemtoReg_in,
output reg Ctl_RegWrite_out,
//
input [ 4:0] Rd_in,
input [31:0] ReadDatafromMem_in, ALUresult_in,
output reg [ 4:0] Rd_out,
output reg [31:0] WriteDatatoReg_out
);

always @(*) begin
Rd_out <= Rd_in;
Ctl_RegWrite_out <= Ctl_RegWrite_in;
WriteDatatoReg_out <= (Ctl_MemtoReg_in == 1) ? ReadDatafromMem_in : ALUresult_in;
end
endmodule