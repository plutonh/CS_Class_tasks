`timescale 1ns / 1ps
//ALU OPERATION
`define _AND_	4'b0000
`define _OR_	4'b0001
`define _ADD_	4'b0010
`define _SUB_	4'b0110
`define _BEQ_	4'b0111	//실제로는 ALU까지 안 감
`define _BNE_	4'b1000	//실제로는 ALU까지 안 감
`define _JAL_	4'b0011	//실제로는 ALU까지 안 감
`define _JALR_ 4'b0010	//ADD랑 코드 똑같음. jalr_out==0이면 ALU까지 안 감.
`define _BLT_	4'b0111
`define _BGE_	4'b1011


module InDecode_branch(
	input [30:0] PC_imm,
	input [31:0] ReadData1, ReadData2,
	input [3:0] ALU_ctl,
	input jalr, jalr_out,
	output reg [1:0] taken,
	output reg [30:0] PC_branch
    );

	always @(*) begin
		case (ALU_ctl)
			`_BEQ_: taken = (ReadData1 == ReadData2) ? 2'b01 : 2'b00;
				
			`_BNE_: 
				taken = (ReadData1 == ReadData2) ? 2'b01 : 2'b00;

			`_JAL_:begin
					PC_branch=PC_imm;
					taken=1;
				end
			`_JALR_: 
				if (jalr==1 && jalr_out ==0) begin
						PC_branch=ReadData1; //imme==0이므로 그냥 RS1
						taken=1;
					end
				else begin
					PC_branch=PC_imm;
					taken=0;
				end
				
			default: begin
					PC_branch=PC_imm;
					taken=0;
				end
		endcase	
end


endmodule
