import lc3b_types::*;

/*
 * ZEXT[offset-n << 1]
 */
module zextlshf1 #(parameter width = 8)
(
    input [width-1:0] in,
    output lc3b_word out
);

assign out = {in, 8'b00000000} << 1;

endmodule : zextlshf1
