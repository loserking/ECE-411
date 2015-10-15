import lc3b_types::*;

/*
 * adds two sixteen bit values for address computation
 */
module sixteenbitadder 
(
     input lc3b_word a,b,
     output lc3b_word out
);

always_comb
begin
	out = a + b;
end
endmodule : sixteenbitadder


