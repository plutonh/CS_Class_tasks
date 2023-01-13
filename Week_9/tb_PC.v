`timescale 1ns / 1ps

module tb_PC;

// Inputs
reg clk;
reg reset;
reg PCSrc;
reg [31:0] PCimm_in;
reg [31:0] PC_in;

// Outputs
wire [31:0] PC_out;

// Instantiate the Unit Under Test (UUT)
PC uut (
.clk(clk),
.reset(reset),
.PCSrc(PCSrc),
.PCimm_in(PCimm_in),
.PC_in(PC_in),
.PC_out(PC_out)
);

initial begin
reset =1;
#24 reset = 0;
end

initial begin
clk =0;
forever #5 clk = ~clk;
end

initial begin
PCSrc =0;
#70 PCSrc = 1;
#10 PCSrc = 0;
end

initial begin
PCimm_in = 0;
#15 PCimm_in = 44;
#10 PCimm_in = 488;
#10 PCimm_in = 16;
#10 PCimm_in = 100;
#10 PCimm_in = 64;
#10 PCimm_in = 72;
#10 PCimm_in = 12;
#10 PCimm_in = 40;
#10 PCimm_in = 56;
#10 PCimm_in = 88;
end

initial begin
PC_in = 0;
#15 PC_in = 4;
#10 PC_in = 8;
#10 PC_in = 12;
#10 PC_in = 16;
#10 PC_in = 20;
#10 PC_in = 24;
#10 PC_in = 28;
#10 PC_in = 32;
#10 PC_in = 36;
#10 $stop;
end
     
endmodule