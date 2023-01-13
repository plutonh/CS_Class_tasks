`timescale 1ns / 1ps

`define  AND  4'b0000
`define  OR   4'b0001
`define  ADD  4'b0010
`define  SUB  4'b0110
`define  BLT  4'b0111
`define  BGE  4'b1000
`define  NOR  4'b1100
`define  SL   4'b1001
`define  SR   4'b1010


module Execution1(
	input 	clk, reset,
	input		flush,	//control hazard탐지
	// control signal
	input 		Ctl_ALUSrc_in, Ctl_MemtoReg_in, Ctl_RegWrite_in,Ctl_MemRead_in, Ctl_MemWrite_in, Ctl_Branch_in, Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in,
	output reg	Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out,	Ctl_MemWrite_out,	Ctl_Branch_out,
	// bypass
	input 		[ 4:0] Rd_in,
	output reg 	[ 4:0] Rd_out,
	input			jal_in, jalr_in,
	output reg	jal_out, jalr_out,

	input 		[31:0] Immediate_in, ReadData1_in, ReadData2_in, EX_MEM_Data, MEM_WB_Data,  PC_in, 
	input 		[ 6:0] funct7_in, 
	input 		[ 2:0] funct3_in, 
	input			[ 1:0] ForwardA_in, ForwardB_in,	//forwarding unit의 signal
	output reg			 Zero_out,
	
	output reg 	[31:0] ALUresult_out, PCimm_out, ReadData2_out, PC_out
	);
	
	//RISC-V
	wire [3:0] ALU_ctl;
	wire [31:0] ALUresult;
	wire zero;
	
	wire instr30 = funct7_in[5];
	reg  [31:0] Data1, Data2;
	wire [31:0] ALU_input1 = Data1;
	wire [31:0] ALU_input2 = Ctl_ALUSrc_in ? Immediate_in:Data2;
	
	//Forward 신호에 의한 MUX
	always @(*) begin
		case (ForwardA_in)
			2'b00: Data1 = ReadData1;
			2'b10: Data1 = EX_MEM_Data;
			2'b01: Data1 = MEM_WB_Data;
		endcase
		
		case (ForwardB_in)
			2'b00: Data2 = ReadData1;
			2'b10: Data2 = EX_MEM_Data;
			2'b01: Data2 = MEM_WB_Data;
		endcase
	end
		
		
	ALU_control1 B0 ( .ALUop({Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in}), 
						.instr30(instr30), .funct3(funct3_in), .ALU_ctl(ALU_ctl) );
	
	ALU1 B1 (	.ALU_ctl(ALU_ctl), .in1(ALU_input1), .in2(ALU_input2), 
				.out(ALUresult), .zero(zero) );
	
	//EX/MEM reg write
	always@(posedge clk) begin
		Ctl_MemtoReg_out	<= (reset | flush) ? 0 : Ctl_MemtoReg_in;
		Ctl_RegWrite_out	<= (reset | flush) ? 0 : Ctl_RegWrite_in;
		Ctl_MemRead_out	<= (reset | flush) ? 0 : Ctl_MemRead_in;
		Ctl_MemWrite_out	<= (reset | flush) ? 0 : Ctl_MemWrite_in;
		Ctl_Branch_out		<= (reset | flush) ? 0 : Ctl_Branch_in;
		
		PC_out				<= (reset) ? 0 : 
		
		
		Rd_out				<= (reset) ? 0 : Rd_in;
		PCimm_out			<= (reset) ? 0 : PC_in + (Immediate_in>>1);
		ReadData2_out		<= (reset) ? 0 : ReadData2_in;
		ALUresult_out		<= (reset) ? 0 : ALUresult;
		Zero_out				<= (reset) ? 0 : zero;
		
	end
endmodule

//////////////////////////////////////////////////////////////////////////////////
module ALU_control1(
	input [1:0] ALUop,
	input instr30,	//funct7의 위에서 2번째 bit. 즉, 6번째 bit.
	input [2:0] funct3,
	output reg [3:0] ALU_ctl
	);


	//ALU_ctl	:	OPERATION
	//4'b0000	:	and	==>ReadData1&ReadData2
	//4'b0001	:	or		==>ReadData1|ReadData2
	//4'b0010	:	add	==>ReadData1+ReadData2(Immediate_in)
	//4'b0110	:	sub	==>ReadData1-ReadData2
	//4'b0111 	:	blt (branch if less than)
	//4'b1000 	:	bge (branch if greater equal)     
	// blt,bge는 zero=1로 만들기 위해서 out=0으로 세팅 
	//4'b1100 	:	nor	==> ~(ReadData1|ReadData2)
	//4'b1001 	:	shift left
	//4'b1010 	:	shift right
	
	always @(*) begin
		casex ({ALUop,funct3,instr30})	//casex로 하면 x를 don't care취급하는데 case로 할경우 명시적 x만 x로 취급한다.
			6'b00_xxx_x :	ALU_ctl	=	`ADD;	// load, store, jal 	=> ADDITION
			6'b01_00x_x :	ALU_ctl	=	`SUB; 	// beq, bne 			=> SUBTRACT (funct3==3'b000)	||	(funct3==3'b001)
			6'b01_100_x :	ALU_ctl	=	`BLT;	// blt					=> BLT(branch if less than) (funct3==3'b100)
			6'b01_101_x :	ALU_ctl	=	`BGE;	// bge					=> BGE(branch if greater than) (funct3==3'b101)
			6'b10_000_0 :	ALU_ctl	=	`ADD;	// add					=> ADDITION (funct3==3'b000 && funct7==7'b0000000)
			6'b10_000_1 :	ALU_ctl	=	`SUB;	// sub					=> SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
			6'b10_111_0 :	ALU_ctl	=	`AND;	// and					=> AND (funct3==3'b111 && funct7==7'b0000000)
			6'b10_110_0 :	ALU_ctl	=	`OR;	// or						=> OR (funct3==3'b110 && funct7==7'b0000000)
			6'b1x_001_x :	ALU_ctl	=	`SL;	// sll					=> SHIFT_LEFT (funct3==3'b001) && (ALUOp=10 || ALUOp=11)
			6'b1x_101_x :	ALU_ctl	=	`SR;	// srl					=> SHIFT_RIGHT (funct3==3'b101)&& (ALUOp=10 || ALUOp=11)
			6'b11_000_x :	ALU_ctl	=	`ADD;	// addi, jalr			=> ADDITION (funct3==3'b000)			
			6'b11_111_x :	ALU_ctl	=	`AND;	// andi					=> AND (funct3==3'b111)	
			default : ALU_ctl = 4'bx;
		endcase
	end

									
endmodule

//////////////////////////////////////////////////////////////////////////////////
module ALU1(
	input [3:0] ALU_ctl,
	input [31:0] in1, in2,
	output reg [31:0] out,
	output zero
	);

	
	always @(*) begin
		case (ALU_ctl)
			`AND :	out = in1 & in2;							// and
			`OR : out = 	in1 | in2;							// or
			`ADD : out = in1 + in2;							// add
			`SUB : out = in1 - in2;							// sub
			`BLT : out = (in1 < in2) ? 32'b00:32'b01;	// blt (branch if less than)
			`BGE : out = (in1 >= in2) ? 32'b00:32'b01;	// bge (branch if greater equal) 
			// blt,bge는 zero=1로 만들기 위해서 out=0으로 세팅  32'b01같이 안 하면 signed 확장의 위험이 있음.
			`NOR : out = ~(in1 | in2);						// nor
			`SL : out = (in1 << in2);						// shift left
			`SR : out = (in1 >> in2);						// shift right
			default :	out = 32'b0;
		endcase
	end
						
	assign zero = 	~|out;	//(ALU_ctl == 4'b0110) 			/ zero로 beq,bne 확인 가능
									//(ALU_ctl == 4'b0111&1000) 	/blt,bge ==> mem stage에서 zero와 branch signal로 branch 여부 결정함.
endmodule
		