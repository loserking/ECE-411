/*8-1 mux*/
module
mux8 #(parameter width = 16)
(
    input [2:0] sel,
    input [width-1:0] a, b, c, d, e, f, g, h,
    output logic [width-1:0] out
);

always_comb
begin
    if (sel == 3'b000)
        out = a;
    else if (sel == 3'b001)
        out = b;
    else if (sel == 3'b010)
        out = c;
    else if (sel == 3'b011)
        out = d;
    else if (sel == 3'b100)
        out = e;
	 else if (sel == 3'b101)
        out = f;
	 else if (sel == 3'b110)
        out = g;
	 else 
        out = h;

end

endmodule
: mux8

