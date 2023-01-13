`timescale 1ns / 1ps

module iMEM(
input clk, reset,
input [31:0] PC_in,
input stall, PCSrc,
output reg [31:0] instruction_out
   );
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
	if(reset)
		instruction_out <= 32'b0;
	else if(~stall)
		instruction_out <= (PCSrc) ? 32'b0 : ROM[PC_in[31:2]];
	else
		instruction_out <= instruction_out;
end
endmodule
