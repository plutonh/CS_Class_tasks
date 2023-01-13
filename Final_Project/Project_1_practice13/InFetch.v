`timescale 1ns / 1ps

module InFetch(
input clk, reset,
input PCSrc, stall, 
input [31:0] PC_branch_in,	//branch target address from MEM stage
output reg [31:0] instruction_out,
output reg [31:0] PC_out	//IF/ID reg의 PC reg
   );
reg  [31:0] PC;
wire [31:0] PC_Next = (PCSrc) ? PC_branch_in : PC + 4;

//모듈 대신 여기에 구현.
always @(posedge clk) begin
	if (reset) PC <=0;
	else if (~stall) PC <= PC_Next;
end

parameter ROM_size = 1024;
reg [31:0] ROM [0:ROM_size-1];


initial begin
	$readmemh("../src/darksocv.rom.mem",ROM); //이걸 명령어 파일로 수정해야 함.
end

//PC_next가 아니라 current로 읽어오는 이유는
//동기적으로 읽고 지속적으로 그 값을 다음 posedge까지 유지하여
//ID stage로 넘겨야 하기 때문이다.
//ROM read시간이 존재하므로 IF/ID reg에 읽은 값을 저장할 수는 없다.

always @(posedge clk) begin
	if(~stall) begin
		if(reset||PCSrc)
			instruction_out <= 32'b0;
		else
			instruction_out <= ROM[PC[31:2]];
	end
end

//IF/ID reg write when not stall
always @(posedge clk) begin	
	if (reset) 
		PC_out <= 0;
	else if(~stall)
		PC_out <= PC;
	else
		PC_out <= PC_out;
end
endmodule
