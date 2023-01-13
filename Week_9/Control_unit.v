module Control_unit(
input [6:0] opcode,
input reset,
output reg [7:0] Ctl_out
);

always @(*) begin
if (reset) // control unit, reset to 0
Ctl_out = 8'b0;
else
case(opcode) // [7] [6] [5] [4] [3] [2]
// add, sub, ...
7'b01100_11 : Ctl_out = 8'b001000_10; // R-type - - RegWrite - - -
// addi, slli : shift left logical immediate rd = rs1 << imm
7'b00100_11 : Ctl_out = 8'b101000_11; // I-type    xxxi  rd, rs1,imm[11:0] ALUSrc - RegWrite - - -
// lw
7'b00000_11 : Ctl_out = 8'b111100_00; // I-type    lxx   rd, rs1,imm[11:0] ALUSrc MemtoReg RegWrite MemRead - -
// sw
7'b01000_11 : Ctl_out = 8'b100010_00; // S-type    sxx   rs1,rs2,imm[11:0] ALUSrc - - - MemWrite -
// beq : branch equal : go to PC+imm<<1
7'b11000_11 : Ctl_out = 8'b000001_01; // SB-type   bcc   rs1,rs2,imm[12:1] - - - - - Branch
// jal : jump and link : rd = PC+4, go to PC+imm<<1
7'b11011_11 : Ctl_out = 8'b001001_00; // UJ-type   jal rd, imm[20:1] - - RegWrite - - Branch
// jalr : jump and link register : rd = PC+4, go to rs1+imm 
7'b11001_11 : Ctl_out = 8'b101001_11; // I-type   jalr  rd, rs1,imm[11:0] ALUSrc - RegWrite - - Branch

default : Ctl_out = 8'b0; 
endcase
end
endmodule