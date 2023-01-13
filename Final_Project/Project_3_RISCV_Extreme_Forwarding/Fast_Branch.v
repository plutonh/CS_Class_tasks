`timescale 1ns / 1ps
//9.019ns
/*opcode

JAL     5'b11011      // jal   rd,imm[xxxxx]
JALR    5'b11001      // jalr  rd,rs1,imm[11:0]
BCC     5'b11000      // bcc   rs1,rs2,imm[12:1]
LCC     5'b00000      // lxx   rd,rs1,imm[11:0]
SCC     5'b01000      // sxx   rs1,rs2,imm[11:0]
MCC     5'b00100      // xxxi  rd,rs1,imm[11:0]
RCC     5'b01100      // xxx   rd,rs1,rs2


���� opcode[4], opcode[1:0]�� ���� ��.
*/

`define __JAL__     3'b111      // jal   rd,imm[xxxxx]
`define __JALR__    3'b101      // jalr  rd,rs1,imm[11:0]
`define __BCC__     3'b100      // bcc   rs1,rs2,imm[12:1]



module NEXT_PC(
	input clk, rst, NOP,
	input [2:0] inst_type, 
	input [1:0] funct2,
	//input [7:0] PC, 
	input signed [7:0] imme,
	input signed [31:0] Data1, Data2,
	output reg [7:0] PC_next,	
	output [7:0] PC4,
	output NOS
    );
	 assign NOS = &PC;	//���� PC�� 8'bff�� �ƹ��͵� �� �Ѵ�.

//PC�� ���⿡ ���������� �����δ� IF�� �����Ѵ�. Ÿ�̹��� Ȯ���غ��� �� �� �ִ�.
//���� �� ������ �ܼ�ȭ�� ���� ����� �ű� ���̴�.
//1cycle ���� ID���� ����� PC�� IF�� PC�� �� �� �ִ� ������ PC_next�� ID���� Ȯ���Ǳ� �����̴�.
//���� PC_next�� IF�� �����Ѵٸ� �׻� ���� PC���� ���� ��ɾ IF���� fetch�ϰ� �ȴ�.
//����� PC�� ID�� �ű� �� �ƴ϶� �����δ� IF�� ������ �����Ѵٴ� ���̴�.
reg [7:0] PC;
always @(posedge clk) begin
	if(rst)
		PC <= 8'hff; //rst�� ���� �� �� ��° posedge�� overflow�� �Բ� �����Ѵ�.
	else if(~NOP) //NOP�̸� PC���� �����ȴ�.
		PC <= PC_next;
end

//load branch hazard�� ���� ����Ŭ�� NOP�� ID�� ���´�.
//ID���� PC�� �׻� ���� ��ɾ�� ����.
//���� NOP�� ���� ���� ����Ŭ�� PC�� load��� PC�� �����ȴ�.
//�׸��� nop�̹Ƿ� PC_next�� PC4�� �����ȴ�.
//�� PC4�� �ٷ� hazard�� �߻��� branch����̴�.
assign PC4 = PC+1;	//jal, jalr�� �� ���� �ܺη� ���޵Ǿ�� �Ѵ�.
wire [7:0] PCimm=PC+imme;
always @(*) begin
	case (inst_type)
		`__JALR__:	PC_next = Data1[7:0];//+imme;
		`__JAL__:	PC_next = PCimm;
		`__BCC__:begin
					case (funct2)
						2'b00: if(Data1==Data2) PC_next = PCimm;
									else PC_next = PC4;
						2'b01: if(Data1!=Data2) PC_next = PCimm;
									else PC_next = PC4;
						2'b10: if(Data1<Data2) PC_next = PCimm;
									else PC_next = PC4;
						2'b11: if(Data1>=Data2) PC_next = PCimm;
									else PC_next = PC4;
					endcase
		end
		default:	PC_next = PC4;
	endcase
end
endmodule



