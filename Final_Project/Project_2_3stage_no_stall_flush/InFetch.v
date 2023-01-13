`timescale 1ns / 1ps
//PC�� 400������ ǥ���� �� ������ �ȴٰ� �Ѵ�. 4�� �ڸ����� �����Ͽ� �� 8���̷� 256(=255*4=1020���� ǥ��)���� ��ɾ ǥ���� �� �ִ�.
module iMEM(
input clk,
input [7:0] PC, //8����
output reg [31:0] Instruction_out
   );
//I-MEM
parameter ROM_size = 256;	//��ɾ��� ��. ���̱� ����.
reg [31:0] ROM [0:ROM_size-1];

initial begin
	$readmemh("../src/darksocv.rom.mem",ROM);
end

always @(posedge clk) begin
	Instruction_out <= ROM[PC];
end
endmodule
