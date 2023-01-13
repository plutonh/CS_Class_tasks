`timescale 1ns / 1ps

module InFetch(
input clk, reset,
input PCSrc, stall, 
input [31:0] PC_branch_in,	//branch target address from MEM stage
output reg [31:0] instruction_out,
output reg [31:0] PC_out	//IF/ID reg�� PC reg
   );
reg  [31:0] PC;
wire [31:0] PC_Next = (PCSrc) ? PC_branch_in : PC + 4;

//��� ��� ���⿡ ����.
always @(posedge clk) begin
	if (reset) PC <=0;
	else if (~stall) PC <= PC_Next;
end

parameter ROM_size = 1024;
reg [31:0] ROM [0:ROM_size-1];


initial begin
	$readmemh("../src/darksocv.rom.mem",ROM); //�̰� ��ɾ� ���Ϸ� �����ؾ� ��.
end

//PC_next�� �ƴ϶� current�� �о���� ������
//���������� �а� ���������� �� ���� ���� posedge���� �����Ͽ�
//ID stage�� �Ѱܾ� �ϱ� �����̴�.
//ROM read�ð��� �����ϹǷ� IF/ID reg�� ���� ���� ������ ���� ����.

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
