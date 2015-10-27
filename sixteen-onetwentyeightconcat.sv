import lc3b_types::*;

/*
 *  2-1 mux combined with a concatenation block (8bit width)
 */
module sixteenonetwentyeightconcat 
(
    input cache_line read_data,
	 input lc3b_word write_data,
	 input [2:0] sel,
    output cache_line out
);

always_comb
begin
	if (sel == 3'b000)
		out = {read_data[127:16],write_data};
	else if (sel == 3'b001)
		out = {read_data[127:32],write_data,read_data[15:0]};
	else if (sel == 3'b010)
		out = {read_data[127:48],write_data,read_data[31:0]};
	else if (sel == 3'b011)
		out = {read_data[127:64],write_data,read_data[47:0]};
	else if (sel == 3'b100)
		out = {read_data[127:80],write_data,read_data[63:0]};
	else if (sel == 3'b101)
		out = {read_data[127:96],write_data,read_data[79:0]};
	else if (sel == 3'b110)
		out = {read_data[127:112],write_data,read_data[95:0]};	
	else
		out = {write_data,read_data[111:0]};
end
endmodule : sixteenonetwentyeightconcat


