/*the datapath*/
import lc3b_types::*;

module cpu_datapath
(
	input clk,
	input logic i_mem_resp,
	input lc3b_word i_mem_rdata,
	input logic d_mem_resp,
	input lc3b_word d_mem_rdata,
	input logic dcache_hit,
	output lc3b_word i_mem_address,
	output lc3b_word i_mem_wdata,
	output logic i_mem_read,
	output logic i_mem_write,
	output logic [1:0]i_mem_byte_enable,
	output lc3b_word d_mem_address,
	output lc3b_word d_mem_wdata,
	output logic d_mem_read,
	output logic d_mem_write,
	output logic dcache_enable,
	output logic [1:0] d_mem_byte_enable

);


//Internal Signals

	//Fetch Signals
		logic [1:0] pcmux_sel;
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
		logic id_ex_v_logic_out;
		lc3b_control_word id_ex_cs_out;
	//Execute signals
		lc3b_word sext5_out;
		lc3b_word sext6_out;
		lc3b_word sext9_out;
		lc3b_word addr2mux_out;
		lc3b_word lshf1_out;
		lc3b_word addr1mux_out;
		lc3b_word addressadder_out;
		lc3b_word sr2mux_out;
		lc3b_word alu_out;
	//Execute-memory signals
		logic load_ex_mem;
		lc3b_word ex_mem_address_out;
		lc3b_control_word ex_mem_cs_out;
		lc3b_word ex_mem_ir_out;
		lc3b_reg ex_mem_cc_out;
		lc3b_word ex_mem_pc_out;
		lc3b_reg ex_mem_dest_out;
		logic ex_mem_v_out;
		lc3b_word ex_mem_aluresult_out;
	//Memory signals
		lc3b_word mem_target;
		logic cccomp_out;
		logic br_taken;
		logic dcache_stall;
	//Memory-wb signals
		logic load_mem_wb;
		lc3b_word mem_wb_address_out;
		lc3b_word mem_wb_data_out;
		lc3b_word mem_wb_pc_out;
		lc3b_control_word mem_wb_cs_out;
		lc3b_word mem_wb_aluresult_out;
		lc3b_word mem_wb_ir_out;
		lc3b_reg mem_wb_dest_out;
		logic mem_wb_v_out;
	//wb signals
		lc3b_word wbmux_out;
		lc3b_reg wb_cc_data;
		logic wb_load_cc;
		logic wb_load_reg;

//End Internal Signals

//Fetch Stage Components

assign i_mem_address = pc_out;
assign i_mem_wdata = 16'b0000000000000000;
assign i_mem_read = 1'b1;
assign i_mem_byte_enable = 2'b11;
assign i_mem_write = 1'b0;
assign load_pc = i_mem_resp & !dcache_stall;
assign load_if_id = i_mem_resp & !dcache_stall;
assign if_id_v_in = !br_taken;

mux3 pcmux
(
	.sel(pcmux_sel),
	.a(pc_plus2_out),
	.b(mem_target),
	.c(),  //Trap signal -- not needed for cp1
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
	.in(if_id_v_in),
	.out(if_id_v_out)
);
//End Fetch - Decode Pipe Components

//Decode Stage Components
control_rom control_rom
(
	.opcode(lc3b_opcode'(if_id_ir_out[15:12])),
	.ir5(if_id_ir_out[5]),
	.ir11(if_id_ir_out[11]),
	.pc(if_id_pc_out),
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
	.load(wb_load_reg),
	.in(wbmux_out), //From wb stage
	.src_a(if_id_ir_out[8:6]),
	.src_b(storemux_out),
	.dest(mem_wb_dest_out), //From wb stage
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

register #(.width(3)) cc
(
	.clk,
	.load(wb_load_cc), //From Wb stage
	.in(wb_cc_data),  //From wb stage
	.out(cc_out)
);

//End Decode Stage Components

//Decode - Execute Pipe Components
assign load_id_ex = id_ex_v_logic_out;
assign id_ex_v_in = !br_taken & if_id_v_out;

id_ex_v_logic id_ex_v_logic
(
	.clk,
	.i_mem_resp(i_mem_resp),
	.dcache_stall(dcache_stall),
	.br_taken(br_taken),
	.out(id_ex_v_logic_out)
);

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
	.load(id_ex_v_logic_out),
	.in(id_ex_v_in),
	.out(id_ex_v_out)
);

//End Decode - Execute pipe components

//Execute Stage Components
sext #(.width(6)) sext6
(
	.in(id_ex_ir_out[5:0]),
	.out(sext6_out)
);

sext #(.width(9)) sext9
(
	.in(id_ex_ir_out[8:0]),
	.out(sext9_out)
);

sext #(.width(5)) sext5
(
	.in(id_ex_ir_out[4:0]),
	.out(sext5_out)
);

lshf1 lshf1
(
	.sel(id_ex_cs_out.lshf),
	.in(addr2mux_out),
	.out(lshf1_out)
);

mux2 addr1mux
(
	.sel(id_ex_cs_out.addr1mux_sel),
	.a(id_ex_pc_out),
	.b(id_ex_sr1_out),
	.f(addr1mux_out)
);

mux4 addr2mux
(
	.sel(id_ex_cs_out.addr2mux_sel),
	.a(16'b0000000000000000),
	.b(sext6_out),
	.c(sext9_out),
	.d(), // sext11 not needed for cp1
	.f(addr2mux_out)
);

sixteenbitadder addressadder
(
	.a(addr1mux_out),
	.b(lshf1_out),
	.out(addressadder_out)
);

mux2 sr2mux
(
	.sel(id_ex_cs_out.sr2mux_sel),
	.a(id_ex_sr2_out),
	.b(sext5_out),
	.f(sr2mux_out)
);

alu alu
(
	.aluop(id_ex_cs_out.aluop),
	.a(id_ex_sr1_out),
	.b(sr2mux_out),
	.f(alu_out)
);

//End Execute Stage components

//Execute-Memory Pipe Components
assign load_ex_mem = !dcache_stall;
assign ex_mem_v_in = !br_taken & id_ex_v_out;

register ex_mem_address
(
	.clk,
	.load(load_ex_mem),
	.in(addressadder_out),
	.out(ex_mem_address_out)
);

csreg ex_mem_cs
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_cs_out),
	.out(ex_mem_cs_out)
);

register ex_mem_ir
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_ir_out),
	.out(ex_mem_ir_out)
);

register #(.width(3)) ex_mem_cc
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_cc_out),
	.out(ex_mem_cc_out)
);

register ex_mem_pc
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_pc_out),
	.out(ex_mem_pc_out)
);


register ex_mem_aluresult
(
	.clk,
	.load(load_ex_mem),
	.in(alu_out),
	.out(ex_mem_aluresult_out)
);

register #(.width(3)) ex_mem_dest
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_dest_out),
	.out(ex_mem_dest_out)
);

register #(.width(1)) ex_mem_v
(
	.clk,
	.load(load_ex_mem),
	.in(ex_mem_v_in),
	.out(ex_mem_v_out)
);

//End Execute - Memory Pipe Components

//Memory Stage Components
assign mem_target = ex_mem_address_out;
assign d_mem_byte_enable = 2'b11;
assign d_mem_wdata = ex_mem_aluresult_out;
assign d_mem_read = ex_mem_cs_out.dcacheR;
assign d_mem_write = ex_mem_cs_out.dcacheW;
assign d_mem_address = ex_mem_address_out;
assign dcache_enable = ex_mem_cs_out.dcache_enable & ex_mem_v_out;
assign pcmux_sel = {1'b0,br_taken};
assign dcache_stall = dcache_enable & !d_mem_resp;
assign mem_wb_v_in = !br_taken & ex_mem_v_out;

cccomp cccomp
(
	.a(ex_mem_cc_out),
	.b(ex_mem_ir_out[11:9]),
	.out(cccomp_out)
);

and3input br_and
(
	.r(ex_mem_v_out),
	.x(ex_mem_cs_out.br_op),
	.y(cccomp_out),
	.z(br_taken)
);

mem_wb_valid_logic mem_wb_valid_logic
(
	.opcode(ex_mem_cs_out.opcode),
	.dcache_stall(dcache_stall),
	.out(load_mem_wb)
);
//End Memory Stage Components

//Memory - Write Back Pipe Components
register mem_wb_address
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_address_out),
	.out(mem_wb_address_out)
);

register mem_wb_data
(
	.clk,
	.load(load_mem_wb),
	.in(d_mem_rdata),
	.out(mem_wb_data_out)
);

csreg mem_wb_cs
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_cs_out),
	.out(mem_wb_cs_out)
);

register mem_wb_pc
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_pc_out),
	.out(mem_wb_pc_out)
);

register mem_wb_aluresult
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_aluresult_out),
	.out(mem_wb_aluresult_out)
);

register mem_wb_ir
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_ir_out),
	.out(mem_wb_ir_out)
);

register #(.width(3)) mem_wb_dest
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_dest_out),
	.out(mem_wb_dest_out)
);

register #(.width(1)) mem_wb_v
(
	.clk,
	.load(load_mem_wb),
	.in(mem_wb_v_in),
	.out(mem_wb_v_out)
);
//End memory - writeback pipe components

//Writeback Stage components

mux4 wbmux
(
	.sel(mem_wb_cs_out.wbmux_sel),
	.a(), //mem_wb_address_out -- not needed for cp1
	.b(mem_wb_data_out),
	.c(), // mem_wb_pc_out -- not needed for cp1
	.d(mem_wb_aluresult_out),
	.f(wbmux_out)
);

gencc gencc
(
	.in(wbmux_out),
	.out(wb_cc_data)
);

	//Writeback load cc and load reg logic
	and2input wb_load_cc_and
	(
		.x(mem_wb_v_out),
		.y(mem_wb_cs_out.load_cc),
		.z(wb_load_cc)
	);
	
	and2input wb_load_reg_and
	(
		.x(mem_wb_v_out),
		.y(mem_wb_cs_out.load_reg),
		.z(wb_load_reg)
	);
	//End writeback load cc and load reg logic
//End Writeback stage components
endmodule : cpu_datapath