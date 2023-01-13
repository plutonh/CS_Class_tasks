`timescale 1ns / 1ps

module iMEM(
input clk, reset,
input [31:0] PC_in,
output reg [31:0] instruction_out
   );
parameter ROM_size = 32;
reg [31:0] ROM [0:ROM_size-1];

integer i;
initial begin
for(i=0;i!=ROM_size;i=i+1) begin
ROM[i] = 32'b0;
end
$readmemh("../src/darksocv.mem",ROM);
end

always @(posedge clk) begin
if(reset) instruction_out <= 32'b0;
else instruction_out <= ROM[PC_in[31:2]];
end
endmodule