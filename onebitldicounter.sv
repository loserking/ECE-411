/*one bit counter module*/

module onebitldicounter
(
	input logic clk,
	input logic d_mem_read,
	input logic d_mem_write,
	input logic d_mem_resp,
	input logic ldi_cs,
	output logic [1:0] out 
);


logic [1:0]	count = 2'b00;


always_comb
begin
	 if(d_mem_resp)
		  count = count + 2'b01;
	 else 
		count = 2'b00;
end


always_comb
begin
	out = count;
end

endmodule: onebitldicounter