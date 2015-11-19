/*logic block for id_ex_valid*/
module id_ex_v_logic
(
	input logic clk,
	input logic i_mem_resp,
	input logic dcache_stall,
	input logic ldi_stall,
	input logic br_taken,
	output logic out
);

logic [1:0] data;

initial
begin
    data = 2'b11;
end

always_ff @(posedge clk)
begin
	 if(i_mem_resp == 1)
		data = 2'b11;
    else 
		data = data - 1'b1;
	 if(data == 2'b00)
		data = 2'b01;
end

always_comb
begin
    if(dcache_stall == 1)
		out = 0;
	 else if(ldi_stall)
		out = 0;
	 else if((data == (2'b11)) || (data == (2'b10)))
		out = 1;
	 else if(br_taken)
		out = 0;
	 else 
		out = 0;
end

endmodule : id_ex_v_logic