/*A 2-1 demux module */
module demux2_1 #(parameter width = 16)
(
	input logic sel,
	input logic [width-1:0] in,
	output logic [width-1:0] outone,
	output logic [width-1:0] outtwo
);


always_comb
begin
	if(sel == 0)
	begin
		outone = in;
		outtwo = 1'b0;
	end
	else
	begin
		outone = 1'b0;
		outtwo = in;
	end
end


endmodule: demux2_1