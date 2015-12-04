import lc3b_types::*;
/*
 * 	Data forwarding unit to output mux selectors for the ALU
 */

module forwarding_unit
(
	input logic clk,
	input logic load_reg,
	input lc3b_reg ex_mem_DR,
	input lc3b_reg mem_wb_DR,
	input lc3b_reg id_ex_dest,
	input lc3b_reg id_ex_SR1,
	input lc3b_reg id_ex_SR2,
	input logic id_ex_sr1_needed,
	input logic id_ex_sr2_needed,
	input logic id_ex_dr_needed,
	input logic ex_mem_sr1_needed,
	input logic ex_mem_sr2_needed,
	input logic ex_mem_dr_needed,
	input logic mem_wb_sr1_needed,
	input logic mem_wb_sr2_needed,
	input logic mem_wb_dr_needed,
	input logic ex_mem_v,
	input logic mem_wb_v,
	
	
	output logic [1:0] forwardmux1_sel,
	output logic [1:0] forwardmux2_sel
);


always_comb
begin

		forwardmux1_sel = 2'b00;
		forwardmux2_sel = 2'b00;


	if(load_reg == 1)
	begin
	
		if((ex_mem_DR == id_ex_SR1)&&(id_ex_sr1_needed) &&(ex_mem_dr_needed) &&(id_ex_dr_needed) && (ex_mem_v))
			forwardmux1_sel = 2'b10;
		else if((mem_wb_DR == id_ex_SR1) && (id_ex_sr1_needed) && (mem_wb_dr_needed) && (id_ex_dr_needed) && (mem_wb_v))
			forwardmux1_sel = 2'b01;
		else 
			forwardmux1_sel = 2'b00;
			
		if((ex_mem_DR == id_ex_SR2) && (id_ex_sr2_needed) &&(ex_mem_dr_needed) && (id_ex_dr_needed) && (ex_mem_v))
			forwardmux2_sel = 2'b10;
		else if((mem_wb_DR == id_ex_SR2) &&(id_ex_sr2_needed) && (mem_wb_dr_needed) && (id_ex_dr_needed) && (mem_wb_v))
			forwardmux2_sel = 2'b01;	
		else 
			forwardmux2_sel = 2'b00;
	end
	else
	begin
		if((id_ex_dest == mem_wb_DR) && (id_ex_dr_needed))
			forwardmux2_sel = 2'b01;
		else if((ex_mem_DR == id_ex_SR1)&&(id_ex_sr1_needed))
			forwardmux1_sel = 2'b11;
		else
			forwardmux2_sel = 2'b00;
	end
	
end
endmodule: forwarding_unit