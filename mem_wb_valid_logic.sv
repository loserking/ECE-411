/*block for calculating the valid bit for ex-mem pipe components*/
import lc3b_types::*;

module mem_wb_valid_logic
(
	input lc3b_opcode opcode,
	input logic d_mem_resp,
	output logic out
);

always_comb
begin
	if((opcode == op_ldr) || (opcode == op_str))
		out = d_mem_resp;
	else
		out = 1'b1;
end

endmodule : mem_wb_valid_logic