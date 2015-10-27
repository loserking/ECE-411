/*the datapath that contains everything for the pipeline CPU*/
import lc3b_types::*;
module pipelineCPU_datapath(
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
/*INTERNAL SIGNALS*/
	//FETCH STAGE INTERNAL SIGNALS//
		lc3b_word pcmux_out;	
		lc3b_word pc_out;
		lc3b_word pc_plus2_out;
		logic nor_gate_out;
		lc3b_word mem_target;
		logic [1:0] pc_mux_sel;
		logic load_pc;
		assign load_pc = 1; //Only for cp1
	//FETCH-DECODE STAGE INTERNAL SIGNALS//
		lc3b_word if_id_pc_out;
		logic load_if_id;
		logic if_id_v_out;
		lc3b_word if_id_ir_out;
	//DECODE STAGE INTERNAL SIGNALS//
		lc3b_reg storemux_out;
		lc3b_reg destmux_out;
		lc3b_word sr1_out;
		lc3b_word sr2_out;
		lc3b_reg cc_out;
		logic dep_stall;
		lc3b_control_word control_store;
	//DECODE-EXECUTE STAGE INTERNAL SIGNAL//
		lc3b_word id_ex_pc_out;
		lc3b_word id_ex_ir_out;
		lc3b_word id_ex_sr1_out;
		lc3b_word id_ex_sr2_out;
		lc3b_word id_ex_cc_out;
		lc3b_reg id_ex_drid_out;
		logic id_ex_v_out;
		logic load_id_ex;
	//EXECUTE STAGE INTERNAL SIGNALS//
		lc3b_word sext5_out;
		lc3b_word sext6_out;
		lc3b_word sext9_out;
		lc3b_word sext11_out;
		lc3b_word addr2mux_out;
		lc3b_word addr1mux_out;
		lc3b_word sr2mux_out;
		lc3b_word lshf1_out;
		lc3b_word zextshf1_out;
		lc3b_word addr3mux_out;
		lc3b_word shft_out;
		lc3b_word alu_out;
		lc3b_word aluresultmux_out;
		logic ex_load_cc_and_out;
		logic ex_load_reg_and_out;
		logic ex_br_stall_and_out;
		lc3b_word address_adder_out;
		lc3b_word zextlshf1_out;
	//EXECUTE-MEMORY STAGE INTERNAL SIGNALS//
		lc3b_control_word ex_mem_cs_out;
		lc3b_word ex_mem_pc_out;
		lc3b_reg ex_mem_cc_out;					
		lc3b_word ex_mem_alu_result_out;
		lc3b_word ex_mem_ir_out;
		lc3b_reg ex_mem_dr_out;
		lc3b_word ex_mem_address_out;
		logic ex_mem_v_out;
		logic load_ex_mem;
	//MEMORY STAGE INTERNAL SIGNALS//
		lc3b_word Dcachesplitmux_out;
		lc3b_word Dcachewritemux_out;
		lc3b_word Dcachereadmux_out;
		logic and1_out;
		logic and2_out;
		logic and3_out; //same as what would be "and4"
		logic we0;
		logic we1;
		logic Dcache_enable;
		logic Dcache_enable_v;
		logic mem_load_cc_valid;
		logic mem_load_reg_valid;
		logic mem_br_stall_valid;
		logic cccomp_out;
		logic orgate_out;
		logic TRAPAND;
		logic JSRAND;
		logic TAKEBR;
		lc3b_word mem_trap;
		logic mem_stall;
		lc3b_word HBzext_out;
		lc3b_word LBzext_out;
		lc3b_word bytefill_out;
		lc3b_word Dcachemux_out;
	//MEMORY-WRITEBACK INTERNAL SIGNALS//
		lc3b_reg mem_wb_dr_out;
		lc3b_word mem_wb_address_out;
		lc3b_word mem_wb_pc_out;
		lc3b_word mem_wb_alu_result_out;
		lc3b_word mem_wb_data_out;
		logic mem_wb_v_out;
		logic load_mem_wb;
		lc3b_control_word mem_wb_cs_out;
	//WRITEBACK INTERNAL SIGNALS//
		logic wb_load_cc_and_out;
		logic wb_load_reg_and_out;
		lc3b_word wb_regfile_data;
		lc3b_reg wb_gencc_out;
/*END INTERNAL SIGNALS*/


/*FETCH STAGE COMPONENTS*/
assign i_mem_address = pc_out;
assign i_mem_write = 1'b0;
assign i_mem_read = 1'b1;
assign i_mem_wdata = 16'b0000000000000000;
assign i_mem_byte_enable = 2'b11;

mux3 pcmux 
(
	.sel(pc_mux_sel), //calculated by BR logic
	.a(pc_plus2_out),
	.b(mem_target), //From MEM_address in MEM STAGE
	.c(mem_trap),//MEM_TRAP is the trap vector 
	.f(pcmux_out)
);

register pc
(
	.clk,
	.load(load_pc),//Not from control rom. HAve to calculate it
	.in(pcmux_out),
	.out(pc_out)
);

plus2 pc_plus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

nor3input if_valid_nor
(
	.a(),//ID.branch_stall
	.b(mem_stall),//signal for memory not being ready
	.c(dep_stall),
	.f(nor_gate_out)
);

and2input if_valid_and
(
	.x(i_mem_resp),
	.y(nor_gate_out),
	.z(load_if_id)
);


/*END FETCH STAGE COMPONENTS*/

/*FETCH-DECODE PIPE COMPONENTS*/
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

/*END FETCH-DECODE PIPE COMPONENTS*/

/*DECODE STAGE COMPONENTS*/
control_rom control_rom
(
	.opcode(lc3b_opcode'(if_id_ir_out[15:12])),
   .ir11(if_id_ir_out[11]),
   .ir5(if_id_ir_out[5]),
   .ctrl(control_store)
);

mux2 #(.width(3)) storemux
(
	.sel(control_store.storemux_sel), //Need to bring this from control rom(storemux_sel)
	.a(if_id_ir_out[2:0]),
	.b(if_id_ir_out[11:9]),
	.f(storemux_out)
);

mux2 #(.width(3)) destmux
(
	.sel(control_store.destmux_sel), //Need to bring this from control rom(destmux_sel)
	.a(if_id_ir_out[11:9]),
	.b(3'b111),
	.f(destmux_out)
);

regfile regfile
(
	.clk,
	.in(wb_regfile_data),//data to load into register from the wb stage
	.src_a(if_id_ir_out[8:6]),
	.src_b(storemux_out),
	.dest(mem_wb_dr_out),// destination register in the wb stage
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

register #(.width(3)) cc
(
	.clk,
	.load(wb_load_cc_and_out),//Signal from WB stage to load cc register	
	.in(wb_gencc_out),//WB_gencc -- the generated condition code data
	.out(cc_out)
);
//Still need branch stall logic//

dependencylogic dependencylogic
(
	.sr1_needed(control_store.sr1_needed), //NEED to bring in from the control store
	.sr2_needed(control_store.sr2_needed), //NEED to bring in from the control store
	.sr1(if_id_ir_out[8:6]),
	.sr2(storemux_out),
	.de_br_op(control_store.br_op), //NEED to bring in from the control store
	.ex_dr(id_ex_drid_out),
	.mem_dr(ex_mem_dr_out),
	.wb_dr(mem_wb_dr_out),
	.v_ex_ld_reg(ex_load_reg_and_out), //Need to get this from the execute stage
	.v_mem_ld_reg(mem_load_reg_valid), //signal from mem that says mem loads register
	.v_wb_ld_reg(wb_load_reg_and_out), //Signal from wb that says wb loads register
	.v_ex_ld_cc(ex_load_cc_and_out), //Need to get this from the execute stage
	.v_mem_ld_cc(mem_load_cc_valid), //Signal from mem that says mem loads cc register
	.v_wb_ld_cc(wb_load_cc_and_out), //Signal from wb that says wb loads cc register
	.dep_stall(dep_stall)
);

/*END DECODE STAGE COMPONENTS*/

/*DECODE-EXECUTE PIPE COMPONENTS*/
assign load_id_ex = 1;

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
	.in(control_store),//Need to take the output of the control store
	.out(id_ex_cs_out)//id_ex_cs_out
);

register id_ex_ir
(
	.clk,
	.load(load_id_ex),
	.in(if_id_ir_out),
	.out(id_ex_ir_out)
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

register #(.width(3)) id_ex_cc
(
	.clk,
	.load(load_id_ex),
	.in(cc_out),
	.out(id_ex_cc_out)
);

register #(.width(3)) id_ex_drid
(
	.clk,
	.load(load_id_ex),
	.in(destmux_out),
	.out(id_ex_drid_out)
);

register #(.width(1)) id_ex_v
(
	.clk,
	.load(load_id_ex),
	.in(load_id_ex),
	.out(id_ex_v_out)
);
/*END DECODE-EXECUTE PIPE COMPONENTS*/


/*EXECUTE STAGE COMPONENTS*/
sext #(.width(5)) sext5
(
     .in(id_ex_ir_out[4:0]),
	 .out(sext5_out)
);

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


sext #(.width(11)) sext11
(
     .in(id_ex_ir_out[10:0]),
	 .out(sext11_out)
);

lshf1 lshf1
(
	.sel(control_store.lshf1),//NEED to get from CONTROL ROM
	.in(addr2mux_out),
	.out(lshf1_out)
);

sixteenbitadder address_adder
(
	.a(addr1mux_out),
	.b(lshf1_out),
	.out(address_adder_out)
);

mux2 addr3mux
(
	.sel(control_store.addr3mux_sel),//addr3mux_sel from control store
	.a(address_adder_out), 
	.b(zextlshf1_out),
	.f(addr3mux_out)
);

zextlshf1 zextlshf1
(
	.in(id_ex_ir_out[7:0]),
	.out(zextlshf1_out)
);

mux4 addr2mux
(
	.sel(control_store.addr2mux_sel), //addr2mux_sel from control store
	.a(16'b0000000000000000),
	.b(sext5_out),
	.c(sext9_out),
	.d(sext11_out),
	.f(addr2mux_out)
);

mux2 addr1mux
(
	.sel(control_store.addr1mux_sel),//addr1mux_sel from control store
	.a(id_ex_pc_out),
	.b(id_ex_sr1_out),
	.f(addr1mux_out)
);

shft shft
(
	.in(id_ex_sr1_out),
	.shiftword(id_ex_ir_out[5:0]),
	.out(shft_out)
);

alu alu
(
	.aluop(control_store.aluop),//Needs to come from Control Store
   .a(id_ex_sr1_out),
	.b(sr2mux_out),
   .f(alu_out)
);

mux2 aluresultmux
(
	.sel(control_store.aluresultmux_sel),//Needs to come from Control Store
	.a(alu_out),
	.b(shft_out),
	.f(aluresultmux_out)
);

mux2 sr2mux
(
	.sel(control_store.sr2mux_sel),//sr2mux_sel from control store
	.a(id_ex_sr2_out),
	.b(sext5_out),
	.f(sr2mux_out)
);

	/*Begin Execute dependency logic*/
	and2input ex_load_cc_and
	(
		.x(control_store.load_cc), //Need to get load_cc from Control Store
		.y(id_ex_v_out),
		.z(ex_load_cc_and_out)
	);
	
	and2input ex_load_reg_and
	(
		.x(control_store.load_regfile), //Need to get load_reg from control store
		.y(id_ex_v_out),
		.z(ex_load_reg_and_out)
	);
	
	and2input ex_br_stall_and
	(
		.x(control_store.br_stall), //Need to get BR stall from control store
		.y(id_ex_v_out),
		.z(ex_br_stall_and_out)
	);
	
/*END EXECUTE STAGE COMPONENTS*/

/*EXECUTE-MEMORY PIPE COMPONENTS*/
assign load_ex_mem = 1;

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
	.in(control_store), 
	.out(ex_mem_cs_out)
);


register ex_mem_pc
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_pc_out), 
	.out(ex_mem_pc_out)
);


register #(.width(3)) ex_mem_cc
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_cc_out),
	.out(ex_mem_cc_out)			
);


register ex_mem_alu_result
(
	.clk,
	.load(load_ex_mem),
	.in(aluresultmux_out),
	.out(ex_mem_alu_result_out)
);


register ex_mem_ir
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_ir_out), 
	.out(ex_mem_ir_out)
);

register #(.width(3)) ex_mem_dr
(
	.clk,
	.load(load_ex_mem),
	.in(id_ex_drid), 
	.out(ex_mem_dr_out)
);


register #(.width(1)) ex_mem_v
(
	.clk,
	.load(load_ex_mem),
	.in(), //input is 1 bit from execute
	.out(ex_mem_v_out)
);
/*END EXECUTE-MEMORY PIPE COMPONENTS*/


/*MEMORY STAGE COMPONENTS*/
assign mem_target = ex_mem_address_out;
assign mem_trap = d_mem_rdata;
assign d_mem_byte_enable = {and2_out,and1_out};
assign d_mem_wdata = Dcachewritemux_out;
assign d_mem_read = (!control_store.dcacherw);
assign d_mem_write = control_store.dcacherw;
assign d_mem_address = ex_mem_address_out;


	/*Begin DCache Read Logic*/
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

	mux2 #(.width(16)) Dcachesplitmux
	(
		 .sel(ex_mem_address_out[0]),
		 .a(LBzext_out),
		 .b(HBzext_out),
		 .f(Dcachesplitmux_out)
	);

	mux2 #(.width(16)) Dcachereadmux
	(
		 .sel(ex_mem_cs_out.dcachereadmux_sel), //FROM control ROM(dcachereadmux_sel)
		 .a(d_mem_rdata), //Output from the D-Cache on read
		 .b(Dcachesplitmux_out),
		 .f(Dcachereadmux_out)
	);
	/*End DCache Read Logic*/
	
	/*Begin DCache Write Logic*/
	bytefill #(.width(8)) bytefill
	(
		  .in(ex_mem_alu_result_out[7:0]),
		  .bytefill_sel(ex_mem_address_out[0]),
		 .out(bytefill_out)
	);

	mux2 #(.width(16)) Dcachewritemux
	(
		 .sel(ex_mem_cs_out.dcachewritemux_sel), //FROM control ROM(dcachewritemux_sel)
		 .a(ex_mem_alu_result_out), 
		 .b(bytefill_out),
		 .f(Dcachewritemux_out)
	);
	/*End DCache Write Logic*/


    /*Begin DCache Write Enable Logic*/
    and2input and1
    (
	    .x(ex_mem_cs_out.dcacherw), //D_CACHE_R/W control signal
	    .y(!ex_mem_address_out[0]),
	    .z(and1_out)

    );
    and2input and2
    (
	    .x(ex_mem_cs_out.dcacherw), //D_CACHE_R/W control signal
	    .y(ex_mem_address_out[0]),
	    .z(and2_out)

    );

    and2input and3
    (
	    .x(control_store.dcacherw), //D_CACHE_R/W control signal
	    .y(), //DATA_SIZE control signal
	    .z(and3_out)

    );


    mux2 #(.width(1)) we_mux1
    (
	    .sel(and3_out),
	    .a(and1_out),
	    .b(1'b1),
	    .f(we0)

    );
    mux2 #(.width(1)) we_mux2
    (
	    .sel(and3_out),
	    .a(and2_out),
	    .b(1'b1),
	    .f(we1)

    );
    /*End DCache Write Enable Logic*/
	 
	 
and2input DCache_enable_andGate
(
	.x(ex_mem_cs_out.dcache_enable), // from control rom dcache_enable
	.y(ex_mem_v),
	.z(Dcache_enable_v)
); 

and2input mem_stall_andGate
(
	.x(ex_mem_cs_out.dcacherw), //DCache_R signal from D cache
	.y(Dcache_enable_v),
	.z(mem_stall)
);



	/*Begin MEM_DEP_CHECK_LOGIC*/
	and2input load_cc
	(
		.x(ex_mem_cs_out.load_cc),//CS load CC signal
		.y(ex_mem_v),
		.z(mem_load_cc_valid)
	);
	and2input load_reg
	(
		.x(ex_mem_cs_out.load_regfile), //CS load REG signal
		.y(ex_mem_v),
		.z(mem_load_reg_valid)
	);
	and2input br_stall
	(
		.x(ex_mem_cs_out.br_stall), //CS BR STALL SIGNAL
		.y(ex_mem_v),
		.z(mem_br_stall_valid)
	);
	/*End MEM_DEP_CHECK_LOGIC*/
	
	/*Begin BR_LOGIC*/
	cccomp cccomp
	(
		.a(ex_mem_cc),
		.b(ex_mem_ir_out[11:9]),
		.out(cccomp_out)
	);
	BR_box magic_box
	(
		.a(TRAPAND),
		.b(JSRAND),
		.c(TAKEBR),
		.out(pc_mux_sel)
	);
	or2input br_or
	(
		.x(),//bring in UNCOND_OP from CS
		.y(),//bring in TRAP_OP from CS
		.z(orgate_out)
	);
	and2input br_and1
	(
		.x(orgate_out),
		.y(ex_mem_v),
		.z(TRAPAND)
	);
	and2input br_and2
	(
		.x(),//bring in JSR_OP from CS
		.y(ex_mem_v),
		.z(JSRAND)
	);
	and3input br_and3
	(
		.r(ex_mem_v),
		.x(ex_mem_cs_out.br_op), //bring in BR_OP from CS
		.y(cccomp_out),
		.z(TAKEBR)
	
	);
	/*END BR_LOGIC*/


/*END MEMORY STAGE COMPONENTS*/

/*MEMORY-WRITEBACK PIPE COMPONENTS*/
assign load_mem_wb = d_mem_resp;

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
	.in(Dcachereadmux_out),//Data from D-Cache
	.out(mem_wb_data_out)
);

csreg mem_wb_cs
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_cs_out), 
	.out(mem_wb_cs_out) //from control store

);

register mem_wb_pc
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_pc_out),
	.out(mem_wb_pc_out)

);

register mem_wb_alu_result
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_alu_result_out),//alu_result from mem phase
	.out(mem_wb_alu_result_out)
);

register mem_wb_ir			//not used in this stage
(						
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_ir_out),//mem_ir from mem stage
	.out()
);

register #(.width(3)) mem_wb_dr
(
	.clk, 
	.load(load_mem_wb),
	.in(ex_mem_dr_out), //3 bit mem_dr signal from mem stage
	.out(mem_wb_dr_out)

);

register #(.width(1)) mem_wb_v
(
	.clk, 
	.load(load_mem_wb),
	.in(), //1 bit input from mem stage !(mem_br_stall)
	.out(mem_wb_v_out) 

);
/*END MEMORY-WRITEBACK PIPE COMPONENTS*/

/*WRITE BACK STAGE COMPONENTS*/

 mux4 wbmux
 (
	.sel(mem_wb_cs_out.wbmux_sel),//wb_mux_sel
	.a(mem_wb_address_out),
	.b(mem_wb_data_out),
	.c(mem_wb_pc_out),
	.d(mem_wb_alu_result_out),
	.f(wb_regfile_data)
 
 );
 
 gencc wb_gencc
 (
	.in(wb_regfile_data),
	.out(wb_gencc_out)
 );

	/*Begin WB stage ld_cc and ld_reg logic*/
	and2input wb_load_cc_and
	(
		.x(mem_wb_cs_out.load_cc),//Needs to be control store ld_cc bit
		.y(mem_wb_v_out),
		.z(wb_load_cc_and_out)
	);
	
	and2input wb_load_reg_and
	(
		.x(mem_wb_cs_out.load_regfile),//Needs to be the control store ld_reg bit
		.y(mem_wb_v_out),
		.z(wb_load_reg_and_out)
	);
	/*End WB stage ld_cc and ld_reg logic*/
	
/*END WRITE BACK STAGE COMPONENTS*/


endmodule : pipelineCPU_datapath
