module tb_assignment_1;
	reg [31:0] a, b;
	wire [31:0] c, d;
	assignment_1 uut (
		.a(a),
		.b(b),
		.c(c),
		.d(d)
	);
	initial begin
		a = 0;
		b = 0;
		#100;
		a = 2018006417;
		b = 2018007092; 
	end
endmodule
