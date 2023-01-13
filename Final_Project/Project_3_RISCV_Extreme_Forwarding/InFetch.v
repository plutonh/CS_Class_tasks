`timescale 1ns / 1ps
//PC는 400까지만 표현할 수 있으면 된다고 한다. 4의 자리부터 시작하여 총 8길이로 256(=255*4=1020까지 표현)개의 명령어를 표현할 수 있다.
//5ns
module iMEM(
input [7:0] PC, //8길이
output [31:0] Instruction_out
   );
//I-MEM
parameter ROM_size = 192;	//명령어의 수. 줄이기 가능.
reg [31:0] ROM [0:ROM_size-1];

initial begin
	$readmemh("../src/darksocv.rom.mem",ROM);
end


//instr[31:2]만 유효하다.
assign Instruction_out = {ROM[PC][31:2], 2'bxx};


endmodule
