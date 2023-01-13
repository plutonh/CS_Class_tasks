`timescale 1ns / 1ps

module multiplier(
input clk, rst,
input [3:0] in1,
input [3:0] in2,
output [7:0] out
);
reg [3:0] multiplier;
reg [7:0] product, multiplicand;
reg [2:0] i;
wire stop, shift, addition, write;

control ctl(
.M(multiplier[0]),
.stop(stop),
.shift(shift),
.addition(addition),
.write(write)
);

always @(posedge clk, negedge rst) begin

product <= (!rst) ? 0 : (addition) ? product + (multiplier[0] * multiplicand) : product;
multiplier <= (!rst) ? in1 : (shift) ? multiplier>>1 : multiplier;
multiplicand <= (!rst) ? in2 : (shift) ? multiplicand<<1 : multiplicand;
i <= (!rst) ? 4 : (shift) ? i-1 : i;
end

assign stop = (i==0) ? 1 : 0;
assign out = write ? product : 0;

endmodule

module control(
input M, stop,
output shift, addition, write
);

assign addition = stop ? 0 : M;
assign shift = stop ? 0 : 1;
assign write = stop;

endmodule