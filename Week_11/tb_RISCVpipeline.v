`timescale 1ns / 1ps

module tb_RISCVpipeline;

// Inputs
reg clk;
reg rst;

// Outputs
wire [31:0] pc;
wire [31:0] ins;

// Instantiate the Unit Under Test (UUT)
RISCVpipeline uut (
.current_pc(pc),
.instruction(ins),
.clk(clk),
.rst(rst)
);

initial begin
rst =1;
#54 rst = 0;
end

initial begin
clk =0;
forever #5 clk = ~clk;
end   
endmodule