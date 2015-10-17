/*module to left shift by one bit*/
import lc3b_types::*;

/*
 * << 1]
 */
module lshf1 #(parameter width = 16)
(
	 input logic sel,
    input [width-1:0] in,
    output lc3b_word out
);

always_comb
begin
	if(sel == 1)
		out = in << 1;
	else
		out = in;
end

endmodule : lshf1
