`timescale 1ns / 1ps

module tb_ALU;

reg [31:0] a_in;
reg [31:0] b_in;
reg [3:0] op;
wire [31:0] result;
wire zero;
wire overflow;

ALU_RCA_32bit uut(
.a_in(a_in),
.b_in(b_in),
.op(op),
.result(result),
.zero(zero),
.overflow(overflow)
);


initial begin
a_in = 0;
b_in = 0;
op = 4'b0000;


#100

a_in = 2000;
b_in = 1000;
op = 4'b0000;
#50

a_in = 2000;
b_in = 1000;
op = 4'b0001;
#50

a_in = 2000;
b_in = 1000;
op = 4'b0010;
#50

a_in = 2000;
b_in = 1000;
op = 4'b0110;
#50

a_in = 1000;
b_in = 1000;
op = 4'b0110;
#50

a_in = 1000;
b_in = 2000;
op = 4'b0110;
#50

a_in = 1000;
b_in = 2000;
op = 4'b1100;
#50

a_in = 1000;
b_in = 2000;
op = 4'b0111;
#50

a_in = 2000;
b_in = 1000;
op = 4'b0111;
#50

a_in = 1000;
b_in = 1000;
op = 4'b0111;
#50

a_in = 32'b01111111111111111111111111111111;
b_in = 1;
op = 4'b0010;
#50;

a_in = 32'b01111111111111111111111111111111;
b_in = 1;
op = 4'b0110;
#50;

a_in = 1;
b_in = 32'b01111111111111111111111111111111;
op = 4'b0110;
#50;

a_in = 32'b10000000000000000000000000000001;
b_in = 32'b01111111111111111111111111111111;
op = 4'b0110;
#50;

a_in = 32'b10000000000000000000000000000001;
b_in = -1;
op = 4'b0010;
#50;

a_in = 32'b10000000000000000000000000000000;
b_in = -1;
op = 4'b0010;
#50;

a_in = 0;
b_in = 32'b10000000000000000000000000000000;
op = 4'b0110;
#50;
end

endmodule