

module BR_box
(
	input logic a,
	input logic b,
	input logic c,
	input logic d,
	
	output logic [1:0] out  

);

always_comb
begin
	
	
	if (a == 1) //TRAP
		out = 2'b10;
	
	else if(c || b) //BR and JSR
		out = 2'b01;
	else if(d) //JMP
		out = 2'b11;
	else 
		out = 2'b00;


end
endmodule: BR_box