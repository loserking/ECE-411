/*calculates and*/

module or4input(
		input wire x, y, q, r,
		output wire z
		
);

assign z = x | y | q | r;

endmodule : or4input
