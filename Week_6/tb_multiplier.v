`timescale 1ns / 1ps

module tb_multiplier;

reg clk;
reg rst;
reg [3:0] in1;
reg [3:0] in2;
wire [7:0] out;

//optimized_multiplier uut(
multiplier uut(
.clk(clk),
.rst(rst),
.in1(in1),
.in2(in2),
.out(out)
);

initial begin
clk = 0;
in1 = 0;
in2 = 0;

#100;
in1 = 7;
in2 = 10;
#15 rst = 1;
#10 rst = 0;
#10 rst = 1;

end

always #10 clk = ~clk;
endmodule