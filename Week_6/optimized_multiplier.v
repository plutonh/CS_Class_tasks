`timescale 1ns / 1ps

module optimized_multiplier( 
input clk, rst,
input [3:0] in1,
input [3:0] in2,
output [7:0] out
);

reg [8:0] product;
reg [2:0] i; 
wire stop, shift, addiction, write, cout; 
wire [3:0] sum;

control ctl(.stop(stop), .M(product[0]), .shift(shift), .addition(addition), .write(write));

fulladder_4bit ALU( .a(product[8:4]), .b(in2), .sum(sum), .cout(cout) );

always @(posedge clk, negedge rst) begin

if (rst==0) begin
product <= in1; 
i <= 4;
end

else if(shift) begin
product <= addition ? ({cout, sum, product[3:0]}>>1) : (product[8:0]>>1);
i <= i-1;
end
end

assign stop = i==0 ? 1 : 0;
assign out = write ? product[7:0] : 0;

endmodule


module control( 
input stop, M,
output shift, addition, write
);
assign write = stop;
assign {shift, addiction} = stop ? 2'b00 : { 1'b1, M}; 

Endmodule