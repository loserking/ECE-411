import lc3b_types::*;

/*
 *  2-1 mux combined with a concatenation block (8bit width)
 */
module eighteightconcat #(parameter width = 8)
(
    input [width-1:0] a,b,
	 input sel,
    output lc3b_word out
);

always_comb
begin
	if (sel == 0)
		out = {a,b};
	else
		out = {b,a};
end
endmodule : eighteightconcat
