module
nor3input #(parameter width = 16)
(
    input [width-1:0] a, b, c,
    output logic [width-1:0] f
);

always_comb
begin
   

	f = !(a || b || c);
	
end

endmodule: nor3input
