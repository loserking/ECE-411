/*calculates and*/

module and3input(
		input logic r, x, y,
		output logic z
		
);

assign z = r & x & y;

endmodule : and3input