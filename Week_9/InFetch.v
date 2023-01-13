`timescale 1ns / 1ps

module InFetch(
input clk, reset,
input PCSrc,
input [31:0] PCimm_in,
output [31:0] instruction_out,
output reg [31:0] PC_out
   );
wire [31:0] PC;
wire [31:0] PC4 = PC + 4;

PC B1_PC(
.clk(clk),
.reset(reset),
.PCSrc(PCSrc),
.PCimm_in(PCimm_in),
.PC_in(PC4),
.PC_out(PC)
);

iMEM B2_iMEM(
.clk(clk),
.reset(reset),
.PC_in(PC),
.instruction_out(instruction_out)
);

always @(posedge clk) begin
if(reset) PC_out <= 0;
else PC_out <= PC;
end
endmodule