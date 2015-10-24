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
		logic if_id_v_out;
		logic load_if_id;
		lc3b_word if_id_pc_out;
		lc3b_word if_id_ir_out;
	//Decode Signals
		lc3b_reg storemux_out;
		lc3b_word sr1_out;
		lc3b_word sr2_out;
		lc3b_reg cc_out;
		lc3b_control_word control_store;
	//Decode - Execute Signals
		lc3b_word id_ex_pc_out;
		lc3b_word id_ex_ir_out;
		lc3b_word id_ex_sr1_out;
		lc3b_word id_ex_sr2_out;
		lc3b_reg id_ex_cc_out;
		lc3b_reg id_ex_dest_out;
		logic id_ex_v_out;
		logic load_id_ex;
		lc3b_control_word id_ex_cs_out;
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

//Fetch - Decode Pipe Components
register if_id_pc
(
	.clk,
	.load(load_if_id),
	.in(pc_plus2_out),
	.out(if_id_pc_out)
);

register if_id_ir
(
	.clk,
	.load(load_if_id),
	.in(i_mem_rdata),
	.out(if_id_ir_out)
);

register #(.width(1)) if_id_v
(
	.clk,
	.load(load_if_id),
	.in(load_if_id),
	.out(if_id_v_out)
);
//End Fetch - Decode Pipe Components

//Decode Stage Components
control_rom control_rom
(
	.opcode(lc3b_opcode'(if_id_ir_out[15:12])),
	.ir5(if_id_ir_out[5]),
	.ir11(if_id_ir_out[11]),
	.ctrl(control_store)
);

mux2 #(.width(3)) storemux
(
	.sel(control_store.storemux_sel),
	.a(if_id_ir_out[2:0]),
	.b(if_id_ir_out[11:9]),
	.f(storemux_out)
);

regfile regfile
(
	.clk,
	.in(), //From wb stage
	.src_a(if_id_ir_out[8:6]),
	.src_b(storemux_out),
	.dest(), //From wb stage
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

register #(.width(3)) cc
(
	.clk,
	.load(), //From Wb stage
	.in(),  //From wb stage
	.out(cc_out)
);
//End Decode Stage Components

//Decode - Execute Pipe Components
register id_ex_pc
(
	.clk,
	.load(load_id_ex),
	.in(if_id_pc_out),
	.out(id_ex_pc_out)
);

csreg id_ex_cs
(
	.clk,
	.load(load_id_ex),
	.in(control_store),
	.out(id_ex_cs_out)
);

register id_ex_sr1
(
	.clk,
	.load(load_id_ex),
	.in(sr1_out),
	.out(id_ex_sr1_out)
);

register id_ex_sr2
(
	.clk,
	.load(load_id_ex),
	.in(sr2_out),
	.out(id_ex_sr2_out)
);

register id_ex_ir
(
	.clk,
	.load(load_id_ex),
	.in(if_id_ir_out),
	.out(id_ex_ir_out)
);

register #(.width(3)) id_ex_cc
(
	.clk,
	.load(load_id_ex),
	.in(cc_out),
	.out(id_ex_cc_out)
);

register #(.width(3)) id_ex_dest
(
	.clk,
	.load(load_id_ex),
	.in(if_id_ir_out[11:9]),
	.out(id_ex_dest_out)
);

register #(.width(1)) id_ex_v
(
	.clk,
	.load(load_id_ex),
	.in(load_id_ex),
	.out(id_ex_v_out)
);

//End Decode - Execute pipe components


endmodule : cpu_datapath