`timescale 1ns / 1ps
//PC�� 400������ ǥ���� �� ������ �ȴٰ� �Ѵ�. 4�� �ڸ����� �����Ͽ� �� 8���̷� 256(=255*4=1020���� ǥ��)���� ��ɾ ǥ���� �� �ִ�.
//5ns
module iMEM(
input [7:0] PC, //8����
output [31:0] Instruction_out
   );
//I-MEM
parameter ROM_size = 192;	//��ɾ��� ��. ���̱� ����.
reg [31:0] ROM [0:ROM_size-1];

initial begin
	$readmemh("../src/darksocv.rom.mem",ROM);
end


//instr[31:2]�� ��ȿ�ϴ�.
assign Instruction_out = {ROM[PC][31:2], 2'bxx};


endmodule
