/*Hazard Detection module*/
import lc3b_types::*;
module hazard_detection
(
	input logic dcacheR,
	input lc3b_reg id_ex_dr,
	input lc3b_reg if_id_src1,
	input lc3b_reg if_id_src2,
	input lc3b_reg if_id_srdr,
	input logic dcacheW,
	input logic id_ex_sr1_needed,
	input logic id_ex_sr2_needed,
	output logic hazard_stall
);


always_comb
begin
	hazard_stall = 0;
	if(dcacheR)
		if(((id_ex_dr == if_id_src1) && (!id_ex_sr1_needed)) || ((id_ex_dr == if_id_src2) && (id_ex_sr2_needed)) || ((dcacheW) && (id_ex_dr == if_id_srdr)))
			//stall the pipe
			hazard_stall = 1;
	else
		hazard_stall = 0;
end

endmodule : hazard_detection