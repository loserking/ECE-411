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
	input lc3b_reg id_ex_SR1,
	input lc3b_reg id_ex_SR2,
	
	output logic [1:0] forwardmux2_sel,
	output logic [1:0] forwardmux1_sel
);

always_comb
begin

		forwardmux1_sel = 2'b00;
		forwardmux2_sel = 2'b00;


if(load_reg == 1)
	begin
	
		
		
		if(ex_mem_DR == id_ex_SR1)
			forwardmux1_sel = 2'b10;
		else if(ex_mem_DR == id_ex_SR2)
			forwardmux2_sel = 2'b10;
		else if(mem_wb_DR == id_ex_SR1)
			forwardmux1_sel = 2'b01;
		else if(mem_wb_DR == id_ex_SR2)
			forwardmux2_sel = 2'b01;
		
		
		else if(ex_mem_DR != id_ex_SR1)
			forwardmux1_sel = 2'b00;
		else if(ex_mem_DR != id_ex_SR2)
			forwardmux2_sel = 2'b00;
		else if(mem_wb_DR != id_ex_SR1)
			forwardmux1_sel = 2'b00;
		else if(mem_wb_DR != id_ex_SR2)
			forwardmux2_sel = 2'b00;
		else 
		begin
			forwardmux1_sel = 2'b00;
			forwardmux2_sel = 2'b00;
		end
	end


end
endmodule: forwarding_unit