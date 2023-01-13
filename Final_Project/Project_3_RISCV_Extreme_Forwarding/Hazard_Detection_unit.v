`timescale 1ns / 1ps

/*opcode

JAL     5'b11011      // jal   rd,imm[xxxxx]
JALR    5'b11001      // jalr  rd,rs1,imm[11:0]
BCC     5'b11000      // bcc   rs1,rs2,imm[12:1]
LCC     5'b00000      // lxx   rd,rs1,imm[11:0]
SCC     5'b01000      // sxx   rs1,rs2,imm[11:0]
MCC     5'b00100      // xxxi  rd,rs1,imm[11:0]
RCC     5'b01100      // xxx   rd,rs1,rs2


jal�� reg�� �������� �����Ƿ�
opcode[4], opcode[1:0]�� ���� ��.
*/


//�� ���������� ���� ld������ branch�� �� ��츸 hazard�� �߻��Ѵ�. 1 NOP�̴�.
//20ns�� �ֱ�� ����� ��� ������ �׻� EXE���� MEM�� LoadData�� ������ �� �ֱ� �����̴�.
//���� �̷� ������ ���ؼ� B-RAM�� Ư���� ����Ͽ� ALUresult�� �񵿱�� �����ؾ� �Ѵ�.
//���� B-RAM�� �񵿱��� read�� �ȴٸ� ����� �����ص� �ȴ�.
//���� ������ �߸��� �� �ƴϴ�. B-RAM�� Ư������ ����� ���̴�.
//�����ε� clock�ֱⰡ ����� ��� Ÿ�̹������� �̷� ������ �������� �� �� �ִ�.
//IF stage�� ����� ���������Ƿ�(I-MEM read�ۿ� �� ��) �� unit�� IF�� �ִ�.
//��Ȯ���� PC ���� �ִ�.
module Hazard_detection_unit(
	input ID_Ctl_MemRead_in,	//load���� �Ǻ�
	input [4:0] ID_Rd, IF_Rs1, IF_Rs2,
	input [2:0] inst_type,
	output reg NOP_out
    );
	 
	always @(*) begin
		case(inst_type)
			//JAL
			3'b111: NOP_out = 1'b0;
			//JALR
			3'b101: NOP_out = (ID_Rd!=5'b0 && ID_Ctl_MemRead_in && ID_Rd==IF_Rs1) ? 1'b1 : 1'b0;
			//BCC
			3'b100: NOP_out = (ID_Rd!=5'b0 && ID_Ctl_MemRead_in && (ID_Rd==IF_Rs1 || ID_Rd==IF_Rs2) ) ? 1'b1 : 1'b0;
			default: NOP_out = 1'b0;
		endcase
	
	end
	 



endmodule
