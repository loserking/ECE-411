import lc3b_types::*;



module
and2 #(parameter width = 16)
(
    input [width-1:0] a, b,
    output logic f
);

always_comb
begin
   

	f = a && b;
	
end

endmodule
: and2