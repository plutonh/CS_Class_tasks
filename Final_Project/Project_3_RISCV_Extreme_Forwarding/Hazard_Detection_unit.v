`timescale 1ns / 1ps

/*opcode

JAL     5'b11011      // jal   rd,imm[xxxxx]
JALR    5'b11001      // jalr  rd,rs1,imm[11:0]
BCC     5'b11000      // bcc   rs1,rs2,imm[12:1]
LCC     5'b00000      // lxx   rd,rs1,imm[11:0]
SCC     5'b01000      // sxx   rs1,rs2,imm[11:0]
MCC     5'b00100      // xxxi  rd,rs1,imm[11:0]
RCC     5'b01100      // xxx   rd,rs1,rs2


jal은 reg를 참조하지 않으므로
opcode[4], opcode[1:0]만 보면 됨.
*/


//이 구현에서는 오직 ld다음에 branch가 올 경우만 hazard가 발생한다. 1 NOP이다.
//20ns의 주기는 충분히 길기 때문에 항상 EXE에서 MEM의 LoadData를 가져올 수 있기 때문이다.
//물론 이런 구현을 위해선 B-RAM의 특성을 고려하여 ALUresult를 비동기로 전달해야 한다.
//만약 B-RAM이 비동기적 read가 된다면 동기로 전달해도 된다.
//따라서 구현이 잘못된 게 아니다. B-RAM의 특수성을 고려한 것이다.
//실제로도 clock주기가 충분히 길면 타이밍적으로 이런 구현이 가능함을 알 수 있다.
//IF stage가 상당히 여유로으므로(I-MEM read밖에 안 함) 이 unit은 IF에 있다.
//정확히는 PC 옆에 있다.
module Hazard_detection_unit(
	input ID_Ctl_MemRead_in,	//load인지 판별
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
