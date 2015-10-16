import lc3b_types::*;

/*
 * ZEXT[offset]
 */
module bytefill #(parameter width = 8)
(
    input [width-1:0] in,
	 input bytefill_sel,
    output lc3b_word out
);

always_comb
begin
	if (bytefill_sel == 0)
		out = {8'b00000000, in};
	else
		out = {in, 8'b00000000};
end
endmodule : bytefill