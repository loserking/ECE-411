/* A module that contains all the logic for calculating dependencies.*/
import lc3b_types::*;

module dependencylogic
(
	input logic sr1_needed,
	input logic sr2_needed,
	input lc3b_reg sr1,
	input lc3b_reg sr2,
	input logic de_br_op,
	input lc3b_reg ex_dr,
	input lc3b_reg mem_dr,
	input lc3b_reg wb_dr,
	input logic v_ex_ld_reg,
	input logic v_mem_ld_reg,
	input logic v_wb_ld_reg,
	input logic v_ex_ld_cc,
	input logic v_mem_ld_cc,
	input logic v_wb_ld_cc,
	output logic dep_stall
);

always_comb
begin
	if((v_ex_ld_reg)&&((ex_dr == sr1)||(ex_dr == sr2)))
		dep_stall = 1;
	else if((v_mem_ld_reg)&&((mem_dr == sr1)||(mem_dr == sr2)))
		dep_stall = 1;
	else if((v_wb_ld_reg)&&((wb_dr == sr1)||(wb_dr == sr2)))
		dep_stall = 1;
	else if((de_br_op)&&((v_ex_ld_cc)||(v_mem_ld_cc)||(v_wb_ld_cc)))
		dep_stall = 1;
	else 
		dep_stall = 0;
end

endmodule : dependencylogic