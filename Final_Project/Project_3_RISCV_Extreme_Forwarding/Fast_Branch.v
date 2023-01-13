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


따라서 opcode[4], opcode[1:0]만 보면 됨.
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
	 assign NOS = &PC;	//만약 PC가 8'bff면 아무것도 안 한다.

//PC를 여기에 구현했지만 실제로는 IF에 존재한다. 타이밍을 확인해보면 알 수 있다.
//단지 논리 구조의 단순화를 위해 여기로 옮긴 것이다.
//1cycle 뒤의 ID에서 계산한 PC가 IF의 PC가 될 수 있는 이유는 PC_next가 ID에서 확정되기 때문이다.
//따라서 PC_next를 IF에 전달한다면 항상 현재 PC값과 같은 명령어를 IF에서 fetch하게 된다.
//결론은 PC를 ID로 옮긴 게 아니라 실제로는 IF에 여전히 존재한다는 것이다.
reg [7:0] PC;
always @(posedge clk) begin
	if(rst)
		PC <= 8'hff; //rst가 끝난 후 두 번째 posedge에 overflow와 함께 시작한다.
	else if(~NOP) //NOP이면 PC값은 유지된다.
		PC <= PC_next;
end

//load branch hazard면 다음 사이클에 NOP이 ID에 들어온다.
//ID에서 PC는 항상 현재 명령어와 같다.
//따라서 NOP에 의해 다음 사이클에 PC는 load명령 PC로 유지된다.
//그리고 nop이므로 PC_next도 PC4로 유지된다.
//이 PC4가 바로 hazard가 발생된 branch명령이다.
assign PC4 = PC+1;	//jal, jalr시 이 값이 외부로 전달되어야 한다.
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



