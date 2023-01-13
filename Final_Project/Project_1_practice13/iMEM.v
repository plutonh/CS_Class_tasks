`timescale 1ns / 1ps

module iMEM(
input clk, reset,
input [31:0] PC_in,
input stall, PCSrc,
output reg [31:0] instruction_out
   );
parameter ROM_size = 1024;
reg [31:0] ROM [0:ROM_size-1];


initial begin
	$readmemh("../src/darksocv.rom.mem",ROM); //이걸 명령어 파일로 수정해야 함.
end

//PC_next가 아니라 current로 읽어오는 이유는
//동기적으로 읽고 지속적으로 그 값을 다음 posedge까지 유지하여
//ID stage로 넘겨야 하기 때문이다.
//ROM read시간이 존재하므로 IF/ID reg에 읽은 값을 저장할 수는 없다.
always @(posedge clk) begin
	if(reset)
		instruction_out <= 32'b0;
	else if(~stall)
		instruction_out <= (PCSrc) ? 32'b0 : ROM[PC_in[31:2]];
	else
		instruction_out <= instruction_out;
end
endmodule
