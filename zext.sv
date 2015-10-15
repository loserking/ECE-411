import lc3b_types::*;

/*
 * ZEXT[offset]
 */
module zext #(parameter width = 4)
(
    input [width-1:0] in,
    output lc3b_word out
);

assign out = in;

endmodule : zext
