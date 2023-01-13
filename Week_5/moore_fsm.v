`timescale 1ns / 1ps

module moore_fsm(
input clk, rst, bypass,
output reg [1:0] out
);
parameter	ST0 = 2'b00,
		ST1 = 2'b01,
		ST2 = 2'b10,
		ST3 = 2'b11;
reg [1:0] state, next;

//Next state logic
always @(state or bypass) begin
	if (bypass && state == ST1) next=ST3;
	else next = state+1;
end

//State register
always @(posedge clk or negedge rst) begin
	if(!rst) state <= ST0;
	else state <= next;
end

//Output logic
always @(posedge clk or negedge rst) begin
	if(!rst) out = 2'b0;	
	else out <= next;
end
endmodule