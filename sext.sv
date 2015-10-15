import lc3b_types::*;

/*
 * SEXT[offset]
 */
module sext #(parameter width = 5)
(
    input [width-1:0] in,
    output lc3b_word out
);

assign out = $signed(in);

endmodule : sext
