/*the datapath*/
import lc3b_types::*;

module cpu_datapath
(
	input clk,
	input logic i_mem_resp,
	input lc3b_word i_mem_rdata,
	input logic d_mem_resp,
	input lc3b_word d_mem_rdata,
	output lc3b_word i_mem_address,
	output lc3b_word i_mem_wdata,
	output logic i_mem_read,
	output logic i_mem_write,
	output logic [1:0]i_mem_byte_enable,
	output lc3b_word d_mem_address,
	output lc3b_word d_mem_wdata,
	output logic d_mem_read,
	output logic d_mem_write,
	output logic [1:0] d_mem_byte_enable

);


//Internal Signals

	//Fetch Signals
		logic pcmux_sel;
		logic load_pc;
		lc3b_word pc_plus2_out;
		lc3b_word pc_out;
		lc3b_word pcmux_out;
	//Fetch-Decode Signals
	
	//Decode Signals
	
	//Decode - Execute Signals
	//Execute signals
	
	//Execute-memory signals
	//Memory signals
	
	//Memory-wb signals
	
	//wb signals
	

//End Internal Signals

//Fetch Stage Components

assign i_mem_address = pc_out;
assign i_mem_wdata = 16'b0000000000000000;
assign i_mem_read = 1'b1;
assign i_mem_byte_enable = 2'b11;

mux2 pcmux
(
	.sel(pcmux_sel),
	.a(pc_plus2_out),
	.b(),
	.f(pcmux_out)
);

plus2 pc_plus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

register pc
(
	.clk,
	.load(load_pc),
	.in(pcmux_out),
	.out(pc_out)
);

//End Fetch Stage Components



endmodule : cpu_datapath