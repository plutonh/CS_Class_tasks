`timescale 1ns / 1ps
/*
PCSrc�� 11�� �� jalr, 10�� �� jal, 01�� �� branch, 00�� �� not branch.
01�� ��쿣 ALU0==1�϶��� taken��.

*/
//6.919ns

module Branch_TARGET_Buffer(
	input clk, rst, taken,
	input [7:0] PC_branch,	
	output [7:0] PC_next, PC4,
	output flush
    );
reg [2:0] WriteAddr;	//�� ��Ҹ� �˷��ش�. ���� ������ ���ڶ� ��� overflow�Ǿ 0���� �ٽ� write�Ѵ�.
	 
parameter PC_size = 8;	//PC_curent(8), TARGET(8), STATE(2)
reg [7:0] TAG[PC_size-1:0], TARGET[PC_size-1:0];
reg [1:0] STATE[1:0];
reg [7:0] PC_prediction;

//////////////////////////////////////////////////////////////////////
//PC
reg [PC_size:0] PC, PC_past;
always @(posedge clk) begin
	if(rst)
		PC <= 8'hff; //rst�� ������ overflow�� �Բ� �����Ѵ�.
	else
		PC <= PC_next;
end
//////////////////////////////////////////////////////////////////////
assign PC4 = PC+8'b1;
assign PC_next = (past_prediction == taken) ? PC_prediction : PC_branch;
assign flush = (past_prediction == taken) ? 1'b0 : 1'b1;

reg prediction, past_prediction;
// BTB����(����)
always @(posedge clk) begin
	past_prediction <= prediction;
	PC_past <= PC;
	if(reset) begin
		STATE[0][1:0]=2'b01;
		STATE[1][1:0]=2'b01;
		STATE[2][1:0]=2'b01;
		STATE[3][1:0]=2'b01;
		STATE[4][1:0]=2'b01;
		STATE[5][1:0]=2'b01;
		STATE[6][1:0]=2'b01;
		STATE[7][1:0]=2'b01;
		WriteAddr <= 3'b0;
	end
	else begin
		//������ Ʋ���� ���.
		if(past_prediction != taken) begin
			if(~|branch_match)begin	//BTB�� ���� ��� ������ not taken�̹Ƿ� Ʋ�ȴٴ� �� taken.
				TAG[WriteAddr] 	<= PC_past;
				TARGET[WriteAddr]	<= PC_branch;
				STATE[WriteAddr]	<= STATE[WriteAddr]+2'b01;
				WriteAddr			<= WriteAddr+3'b1;
			end
			else begin	//BTB�� �־��µ� Ʋ�ȴٸ� 11->10->01  00->01->10
				STATE[branch_num] <= (past_prediction) ? STATE[branch_num]-2'b1 : STATE[branch_num]+2'b1;
			end
		end
		//������ ���� ��� BTB�� �����Ҷ��� ����
		else begin
			if(|branch_match)begin //�¾����Ƿ� 10->11->11   01->00->00
				STATE[branch_num][0] <= STATE[branch_num][1];
			end
		end
	end
end

//PC����(�񵿱�)
always @(*) begin
	if (reset) begin
		prediction = 1'b0;
		PC_prediction = 8'bx;
	end
	else begin
		if(|current_match) begin	//BTB�� ���� ���
			prediction = TAG[current_num][1];
			//�׻� ���� ������ �¾Ҵٰ� �����ϰ� ���� ���� ����
			PC_prediction = (prediction)? TARGET[current_match] : PC4;
		end
		else begin
			prediction = 1'b0;
			PC_prediction = PC4;
		end
	end
end




// �ּ� ����
genvar i;
generate 
for(i=0; i<8; i=i+1) begin: FIND_ADDRESS
always @(*) begin
	current_match[i] = (PC_current == TAG[i]) ?1:0;
	branch_match[i] = (PC_branch == TARGET[i]) ?1:0;
end
end
endgenerate

always @(*) begin
	case (branch_match)
		8'b1: branch_num = 0;
		8'b10: branch_num = 1;
		8'b100: branch_num = 2;
		8'b1000: branch_num = 3;
		8'b10000: branch_num = 4;
		8'b100000: branch_num = 5;
		8'b1000000: branch_num = 6;
		8'b10000000: branch_num = 7;
		default: branch_num = 3'bx;
	endcase
	case (current_match)
		8'b1: current_num = 0;
		8'b10: current_num = 1;
		8'b100: current_num = 2;
		8'b1000: current_num = 3;
		8'b10000: current_num = 4;
		8'b100000: current_num = 5;
		8'b1000000: current_num = 6;
		8'b10000000: current_num = 7;
		default: current_num = 3'bx;
	endcase
end


endmodule
