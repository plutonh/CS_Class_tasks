v`timescale 1ns / 1ps

module PC(
input clk, reset,
input PCSrc,
input [31:0] PCimm_in,
input [31:0] PC_in,
output reg [31:0] PC_out
);
always @(posedge clk) begin
if(reset) PC_out <= 0;
else if(PCSrc) PC_out <= PCimm_in;
else PC_out <= PC_in;
end
endmodule