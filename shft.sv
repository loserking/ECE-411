/*A module that does the shift operations for the ALU */

import lc3b_types::*;


module shft #(parameter width = 16)
(
    input [width-1:0] in,
	 input [5:0]shiftword,
    output lc3b_word out
);

always_comb
begin
	if(shiftword[4] == 0)
		out = in << shiftword[3:0];
	else
	begin
		if(shiftword[5] == 0)
			out = in >> shiftword[3:0];
		else
			out = $signed(in) >>> shiftword[3:0];
	end
end

endmodule : shft

