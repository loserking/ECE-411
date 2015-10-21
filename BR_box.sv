import lc3b_types::*;

module BR_box
(
	input wire a,
	input wire b,
	input wire c,
	
	output logic [1:0] out  

);

always_comb
begin
	
	
	if (a == 1) /*TRAPAND ==1*/
		out = 2'b10;
	
	else if(c || b) /*TAKEBR or JSRAND*/
		out = 2'b01;
	else
		out = 2'b00;


end
endmodule: BR_box