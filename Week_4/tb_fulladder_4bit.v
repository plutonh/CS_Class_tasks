module tb_fulladder_4bit;
reg [3:0] a;
reg [3:0] b;

wire [3:0] sum;
wire cout;

integer k;

fulladder_4bit uut(
.a(a),
.b(b),
.sum(sum),
.cout(cout)
);

initial begin
forever begin
for(k=0;k<16;k=k+1) begin
b=k;
a=k/2;
#50;
end
end
end

endmodule