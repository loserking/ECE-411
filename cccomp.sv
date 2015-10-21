import lc3b_types::*;

module cccomp
(
	input lc3b_nzp a,
	input lc3b_reg b,
	
	output logic out  

);

always_comb
begin
	
	
	if ((a[0]& b[0])| (a[1] &b[1]) | (a[2] &b[2]))
	/*if((cccomp & cc) != 3'b1)*/
		out <= 1'b1;
	
	else 
		out <= 1'b0;


end
endmodule: cccomp