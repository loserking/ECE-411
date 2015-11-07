/*block for calculating the valid bit for ex-mem pipe components*/
import lc3b_types::*;

module mem_wb_valid_logic
(
	input lc3b_opcode opcode,
	input logic dcache_stall,
	output logic out
);

always_comb
begin
	if(dcache_stall)
		out = 1'b0;
	else
		out = 1'b1;
end

endmodule : mem_wb_valid_logic