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
	input logic idle_state,
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
	output logic [1:0] d_mem_byte_enable,
	output logic br_taken

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
		logic if_id_v_in;
	//Decode Signals
		lc3b_reg storemux_out;
		lc3b_word sr1_out;
		lc3b_word sr2_out;
		lc3b_reg cc_out;
		lc3b_control_word control_store;
		logic raw_hazard_stall;
		logic uncond_pipe_flush;
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
		logic id_ex_v_in;
		lc3b_reg dest_mux_out;
		lc3b_reg id_ex_src1_out;
		lc3b_reg id_ex_src2_out;
	//Execute signals
		lc3b_word sext5_out;
		lc3b_word sext6_out;
		lc3b_word sext9_out;
		lc3b_word sext11_out;
		lc3b_word addr2mux_out;
		lc3b_word lshf1_out;
		lc3b_word addr1mux_out;
		lc3b_word addr3mux_out;
		lc3b_word zextlshf_out;
		lc3b_word addressadder_out;
		lc3b_word sr2mux_out;
		lc3b_word alu_out;
		lc3b_word shft_out;
		lc3b_word alu_result_mux_out;
		lc3b_word forwardmux1_out;
		lc3b_word forwardmux2_out;
		logic [1:0] forwardmux1_sel;
		logic [1:0] forwardmux2_sel;
	//Execute-memory signals
		logic load_ex_mem;
		lc3b_word ex_mem_address_out;
		lc3b_control_word ex_mem_cs_out;
		lc3b_word ex_mem_ir_out;
		lc3b_reg ex_mem_cc_out;
		lc3b_word ex_mem_pc_out;
		lc3b_reg ex_mem_dest_out;
		logic uncond_or_trap;
		logic ex_mem_v_out;
		lc3b_word ex_mem_aluresult_out;
		logic ex_mem_v_in;
		lc3b_reg ex_mem_src1_out;
		lc3b_reg ex_mem_src2_out;
	//Memory signals
		lc3b_word mem_target;
		lc3b_word mem_trap;
		logic cccomp_out;
		logic dcache_stall;
		logic jsr_taken;
		logic trap_taken;
		lc3b_word dcacheaddressmux_out;
		logic dcacheaddressmux_sel;
		logic ldi_stall;
		logic [1:0] ldisticounterout;
		lc3b_word HBzext_out;
		lc3b_word LBzext_out;
		lc3b_word dcachemux_out;
		lc3b_word dcachemux2_out;
		lc3b_word bytefill_out;
		lc3b_word dcachewritemux_out;
		logic andWE0_out;
		logic andWE1_out;
		logic andWE_sel_out;
		logic WE0;
		logic WE1;
		logic mem_wb_data_mux_sel;
		lc3b_word mem_wb_data_mux_out;
		lc3b_word ldistireg_out;
		logic load_ldistireg;
		logic dcacheRmux_sel;
		logic dcacheWmux_sel;
		logic dcacheRmux_out;
		logic dcacheWmux_out;
		logic cccompmux_sel;
		logic wbcccomp_out;
		logic cccompmux_out;
		lc3b_reg wbgencc_out;
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
		logic mem_wb_v_in;
		lc3b_reg mem_wb_src1_out;
		lc3b_reg mem_wb_src2_out;
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
//assign load_pc = i_mem_resp & !dcache_stall & !ldi_stall & !raw_hazard_stall;
assign load_if_id = i_mem_resp & !dcache_stall & !raw_hazard_stall;

always_comb
begin
	if(i_mem_resp)
		load_pc = i_mem_resp & !dcache_stall & !ldi_stall & !raw_hazard_stall;
	else if(!i_mem_resp && br_taken && (mem_target == 16'b0000001011000110))
		load_pc =  1;
	else if(!i_mem_resp && ex_mem_cs_out.jmp_op &&(ex_mem_aluresult_out == 16'b0000001101100010))
		load_pc = 1;
	else
		load_pc = i_mem_resp & !dcache_stall & !ldi_stall & !raw_hazard_stall;
end

mux4 pcmux
(
	.sel(pcmux_sel),
	.a(pc_plus2_out),
	.b(mem_target),										
	.c(mem_trap),  										
	.d(ex_mem_aluresult_out), 								
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
hazard_detection hazard_detection
(
	.dcacheR(id_ex_cs_out.dcacheR),
	.id_ex_dr(id_ex_dest_out),
	.if_id_src1(if_id_ir_out[8:6]),
	.if_id_src2(if_id_ir_out[2:0]),
	.if_id_srdr(if_id_ir_out[11:9]),
	.dcacheW(control_store.dcacheW),
	.id_ex_sr1_needed(id_ex_cs_out.sr1_needed),
	.id_ex_sr2_needed(id_ex_cs_out.sr2_needed),
	.uncond_op(ex_mem_cs_out.uncond_op),
	.uncond_pipe_flush(uncond_pipe_flush),
	.raw_hazard_stall(raw_hazard_stall)
);

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




mux2 #(.width(3)) dest_mux
(
	.sel(control_store.dest_mux_sel),
	.a(if_id_ir_out[11:9]),
	.b(3'b111), //hardcode 111
	.f(dest_mux_out)
);

//End Decode Stage Components

//Decode - Execute Pipe Components
assign load_id_ex = id_ex_v_logic_out;


id_ex_v_logic id_ex_v_logic
(
	.clk,
	.i_mem_resp(i_mem_resp),
	.dcache_stall(dcache_stall),
	.ldi_stall(ldi_stall),
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
	.in(dest_mux_out),
	.out(id_ex_dest_out)
);

register #(.width(3)) id_ex_src1
(
	.clk,
	.load(load_id_ex),
	.in(if_id_ir_out[8:6]),
	.out(id_ex_src1_out)
);

register #(.width(3)) id_ex_src2
(
	.clk,
	.load(load_id_ex),
	.in(storemux_out),
	.out(id_ex_src2_out)
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

sext #(.width(11)) sext11
(
	.in(id_ex_ir_out[10:0]),
	.out(sext11_out)


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
	.d(sext11_out), 
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
	.a(forwardmux1_out),
	.b(forwardmux2_out),
	.f(alu_out)
);


shft shft
(
	.in(forwardmux1_out),
	.shiftword(id_ex_ir_out[5:0]),
	.out(shft_out)
);

mux2 alu_result_mux
(
	.sel(id_ex_cs_out.alu_result_mux_sel),
	.a(alu_out), //default 0 for just alu_out
	.b(shft_out), // 1 for when we shift
	.f(alu_result_mux_out)

);

zextlshf1 zextlshf
(
	.in(id_ex_ir_out[7:0]),
	.out(zextlshf_out)

);

mux2 addr3mux
(
	.sel(id_ex_cs_out.addr3mux_sel),
	.a(addressadder_out),
	.b(zextlshf_out),
	.f(addr3mux_out)

);


/*begin data forwarding*/

forwarding_unit forwarding_unit
(
	.clk,
	.load_reg(id_ex_cs_out.load_reg),
	.ex_mem_DR(ex_mem_dest_out),
	.mem_wb_DR(mem_wb_dest_out),
	.id_ex_dest(id_ex_dest_out),
	.id_ex_SR1(id_ex_src1_out),
	.id_ex_SR2(id_ex_src2_out),
	.id_ex_sr1_needed(id_ex_cs_out.sr1_needed),
	.id_ex_sr2_needed(id_ex_cs_out.sr2_needed),
	.id_ex_dr_needed(id_ex_cs_out.dr_needed),
	.ex_mem_sr1_needed(ex_mem_cs_out.sr1_needed),
	.ex_mem_sr2_needed(ex_mem_cs_out.sr2_needed),
	.ex_mem_dr_needed(ex_mem_cs_out.dr_needed),
	.mem_wb_sr1_needed(mem_wb_cs_out.sr1_needed),
	.mem_wb_sr2_needed(mem_wb_cs_out.sr2_needed),
	.mem_wb_dr_needed(mem_wb_cs_out.dr_needed),
	.ex_mem_v(ex_mem_v_out),
	.mem_wb_v(mem_wb_v_out),
	.forwardmux1_sel(forwardmux1_sel),
	.forwardmux2_sel(forwardmux2_sel)
);

mux4 forwardmux1
(
	.sel(forwardmux1_sel),
	.a(id_ex_sr1_out),
	.b(wbmux_out),
	.c(ex_mem_aluresult_out),
	.d(ex_mem_address_out),
	.f(forwardmux1_out)

);

mux3 forwardmux2
(
	.sel(forwardmux2_sel),
	.a(sr2mux_out),
	.b(wbmux_out),
	.c(ex_mem_aluresult_out),
	.f(forwardmux2_out)

);
/*end data forwarding */

//End Execute Stage components

//Execute-Memory Pipe Components
assign load_ex_mem = !dcache_stall & !ldi_stall;


register ex_mem_address
(
	.clk,
	.load(load_ex_mem),
	.in(addr3mux_out),
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
	.in(alu_result_mux_out),
	.out(ex_mem_aluresult_out)
);

register #(.width(3)) ex_mem_dest
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_dest_out),
	.out(ex_mem_dest_out)
);

register #(.width(3)) ex_mem_src1
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_src1_out),
	.out(ex_mem_src1_out)
);

register #(.width(3)) ex_mem_src2
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_src2_out),
	.out(ex_mem_src2_out)
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
assign mem_trap = d_mem_rdata;
assign d_mem_wdata = dcachewritemux_out;

assign d_mem_read = dcacheRmux_out;
assign d_mem_write = dcacheWmux_out;

always_comb
begin
	if((ex_mem_cs_out.sti_op) &&(ldisticounterout == 2'b00))
	begin
		dcacheRmux_sel = 1;
		dcacheWmux_sel = 1;
	end
	else
	begin
		dcacheRmux_sel = 0;
		dcacheWmux_sel = 0;
	end
end

assign d_mem_address = dcacheaddressmux_out;
assign d_mem_byte_enable[1] = WE1;
assign d_mem_byte_enable[0] = WE0;

assign dcache_enable = ex_mem_cs_out.dcache_enable & ex_mem_v_out;
assign dcache_stall = dcache_enable & !d_mem_resp;
logic [2:0] condition;

always_comb
begin
	if_id_v_in = !br_taken  & !uncond_pipe_flush;
	id_ex_v_in = !br_taken & if_id_v_out & !uncond_pipe_flush; 
	mem_wb_v_in = 	!br_taken & ex_mem_v_out;
	if(if_id_ir_out == 16'b1110001000101111)
		ex_mem_v_in = 0;
	else
		ex_mem_v_in = !br_taken & id_ex_v_out  & !uncond_pipe_flush;
	condition = 3'b100;
	
	if(!idle_state && (mem_wb_cs_out.opcode == op_str) && (if_id_ir_out == mem_wb_ir_out))
	begin
		mem_wb_v_in = 0;
		ex_mem_v_in = 0;
		id_ex_v_in = 0;
		if_id_v_in = 1;
		condition = 3'b001;
	end
	if(!idle_state && ex_mem_cs_out.load_reg)
	begin
		mem_wb_v_in = 1;
		ex_mem_v_in = 0;
		id_ex_v_in = 0;
		if_id_v_in = 0;
		condition = 3'b000;
	end
	if(!idle_state && ex_mem_cs_out.br_op && mem_wb_cs_out.load_reg)
	begin
		mem_wb_v_in = 1;
		ex_mem_v_in = 1;
		id_ex_v_in = 0;
		if_id_v_in = 0;
		condition = 3'b010;
	end
	if(((mem_wb_src1_out == mem_wb_dest_out)||(mem_wb_src2_out == mem_wb_dest_out))&& (mem_wb_cs_out.load_reg) && (!idle_state) && (mem_wb_cs_out.opcode == op_add))
	begin
		if_id_v_in = 0;
		id_ex_v_in = !br_taken & if_id_v_out & !uncond_pipe_flush; 
		ex_mem_v_in = 0;
		if(if_id_ir_out == 16'b0001100001100011)
			mem_wb_v_in = 1;
		else
			mem_wb_v_in = 0;
		
		condition = 3'b011;
	end
	
end

assign uncond_or_trap = (((ex_mem_cs_out.uncond_op) || (ex_mem_cs_out.trap_op)) && (!ex_mem_cs_out.jsr_op) && (!ex_mem_cs_out.jmp_op));
assign jsr_taken = ex_mem_cs_out.jsr_op & ex_mem_v_out;
assign trap_taken = uncond_or_trap & ex_mem_v_out;
assign load_ldistireg = d_mem_resp;


mux2 #(.width(1)) dcacheRmux
(
	.sel(dcacheRmux_sel),
	.a(ex_mem_cs_out.dcacheR),
	.b(1'b1),
	.f(dcacheRmux_out)
);

mux2 #(.width(1)) dcacheWmux
(
	.sel(dcacheWmux_sel),
	.a(ex_mem_cs_out.dcacheW),
	.b(1'b0),
	.f(dcacheWmux_out)
);

/*Begin LDI logic*/
always_comb
begin
	if((ldisticounterout == 2'b00) && (!d_mem_resp))
	begin
		ldi_stall = 0;
		dcacheaddressmux_sel = 0;
	end
	else if((ldisticounterout == 2'b00) && (d_mem_resp)&&(ex_mem_cs_out.ldi_op || ex_mem_cs_out.sti_op))
	begin
		ldi_stall = 1;
		dcacheaddressmux_sel = 0;
	end
		else if((ldisticounterout == 2'b01)&&(ex_mem_cs_out.ldi_op || ex_mem_cs_out.sti_op))
	begin
		ldi_stall = 0;
		dcacheaddressmux_sel = 1;
	end
	else if((ldisticounterout == 2'b01)&&(ex_mem_cs_out.ldi_op || ex_mem_cs_out.sti_op)&&(d_mem_resp))
	begin
		ldi_stall = 0;
		dcacheaddressmux_sel = 0;
	end
	else if(ldisticounterout == 2'b10)
	begin
		ldi_stall = 0;
		dcacheaddressmux_sel = 0;
	end
	else
	begin
		ldi_stall = 0;
		dcacheaddressmux_sel = 0;
	end
end
/*End LDI Stall Logic*/

twobitcounter ldisticounter
(
	.clk,
	.d_mem_resp(d_mem_resp),
	.ldi_op(ex_mem_cs_out.ldi_op),
	.sti_op(ex_mem_cs_out.sti_op),
	.dcache_stall(dcache_stall),
	.count(ldisticounterout)
);

mux2 dcacheaddressmux
(
	.sel(dcacheaddressmux_sel),
	.a(ex_mem_address_out),
	.b(ldistireg_out),
	.f(dcacheaddressmux_out)
);

register ldistireg
(
	.clk,
	.load(load_ldistireg),
	.in(d_mem_rdata),
	.out(ldistireg_out)
);

cccomp cccomp
(
	.a(ex_mem_cc_out),
	.b(ex_mem_ir_out[11:9]),
	.out(cccomp_out)
);

gencc wbgencc
(
	.in(mem_wb_aluresult_out),
	.out(wbgencc_out)
);


cccomp wbcccomp
(
	.a(wbgencc_out),
	.b(ex_mem_ir_out[11:9]),
	.out(wbcccomp_out)
);

always_comb
begin
	if(mem_wb_cs_out.load_cc == 1)
		cccompmux_sel = 1;
	else
		cccompmux_sel = 0;
end

mux2 #(.width(1)) cccompmux
(
	.sel(cccompmux_sel),
	.a(cccomp_out),
	.b(wbcccomp_out),
	.f(cccompmux_out)
);

and3input br_and
(
	.r(ex_mem_v_out),
	.x(ex_mem_cs_out.br_op),
	.y(cccompmux_out),
	.z(br_taken)
);


mem_wb_valid_logic mem_wb_valid_logic
(
	.ldi_cs(ex_mem_cs_out.ldi_op),
	.ldi_stall(ldi_stall),
	.dcache_stall(dcache_stall),
	.out(load_mem_wb)
);

BR_box BR_box
(
	.a(trap_taken),
	.b(jsr_taken),
	.c(br_taken),
	.d(ex_mem_cs_out.jmp_op),
	.out(pcmux_sel)
);



/*LDB*/
zext #(.width(8)) HBzext
(
	.in(d_mem_rdata[15:8]),
	.out(HBzext_out)
);

zext #(.width(8)) LBzext
(
	.in(d_mem_rdata[7:0]),
	.out(LBzext_out)
);



mux2 dcachemux
(
	.sel(ex_mem_address_out[0]),
	.a(LBzext_out),
	.b(HBzext_out),
	.f(dcachemux_out)

);

mux2 dcachemux2
(
	.sel(ex_mem_cs_out.d_mem_byte_sel),
	.a(d_mem_rdata),
	.b(dcachemux_out),
	.f(dcachemux2_out)

);
/*STB*/

bytefill #(.width(8)) bytefill
(
	.in(ex_mem_aluresult_out[7:0]),
	.bytefill_sel(ex_mem_address_out[0]),
	.out(bytefill_out)
);

mux2 dcachewritemux
(
	.sel(ex_mem_cs_out.stb_op),
	.a(ex_mem_aluresult_out), //this is the case for sti as well
	.b(bytefill_out), //stb uses the bytebill though
	.f(dcachewritemux_out)
);

and2input andWE0
(
	.x(ex_mem_cs_out.dcacheW),
	.y(!ex_mem_address_out[0]),
	.z(andWE0_out)
);

and2input andWE1
(
	.x(ex_mem_cs_out.dcacheW),
	.y(ex_mem_address_out[0]),
	.z(andWE1_out)
);

and2input andWE_sel
(
	.x(ex_mem_cs_out.dcacheW),
	.y(ex_mem_cs_out.stb_op),
	.z(andWE_sel_out)
);

mux2 #(.width(1)) WE0mux
(
	.sel(andWE_sel_out),
	.a(1'b1),
	.b(andWE0_out),
	.f(WE0)
);

mux2 #(.width(1)) WE1mux
(
	.sel(andWE_sel_out),
	.a(1'b1),
	.b(andWE1_out),
	.f(WE1)
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
	.in(dcachemux2_out),
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

register #(.width(3)) mem_wb_src1
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_src1_out),
	.out(mem_wb_src1_out)
);

register #(.width(3)) mem_wb_src2
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_src2_out),
	.out(mem_wb_src2_out)
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
	.a(mem_wb_address_out), //mem_wb_address_out -- not needed for cp1
	.b(mem_wb_data_out),
	.c(mem_wb_pc_out), 
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
