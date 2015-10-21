/*calculates and*/

module and3input(
		input wire r, x, y,
		output wire z
		
);

assign z = r & x & y;

endmodule : and3input