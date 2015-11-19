/*block for calculating the valid bit for ex-mem pipe components*/
module mem_wb_valid_logic
(
	input logic ldi_cs,
	input logic ldi_stall,
	input logic dcache_stall,
	output logic out
);

always_comb
begin
	if(dcache_stall)
		out = 1'b0;
	else if(ldi_stall)
		out = 1'b0;
	else
		out = 1'b1;
end

endmodule : mem_wb_valid_logic