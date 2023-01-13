`timescale 1ns / 1ps

module mealy_fsm(clk, rst, din_bit, dout_bit);
input clk, rst, din_bit;
output dout_bit;
reg [2:0] state, next;
parameter 	start = 3'b000,
		st1 = 3'b001,
		st2 = 3'b010,
		st3 = 3'b011,
		st4 = 3'b100;

// next state logic block
always @(state or din_bit) begin
	#0
	case(state)
		start: next = (din_bit==0) ? st1:start;
		st1: next = (din_bit==0) ? st1:st2;
		st2: next = (din_bit==0) ? st1:st3;
		st3: next = (din_bit==0) ? st4:start;
		st4: next = (din_bit==0) ? st1:st2;
	endcase
end

// state register block
always @(posedge clk or negedge rst) begin
	if (rst==0) state <= start;
	else state <= next;
end

//output logic block
assign dout_bit = (state == st3 && din_bit == 0);
endmodule