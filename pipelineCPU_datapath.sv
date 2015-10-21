/*the datapath that contains everything for the pipeline CPU*/
module pipelineCPU_datapath(
	input clk,
	input i_mem_resp,
	input lc3b_word dcache_rdata
	
);
/*INTERNAL SIGNALS*/
	//FETCH STAGE INTERNAL SIGNALS//
		lc3b_word pcmux_out;	
		lc3b_word pc_out;
		lc3b_word pc_plus2_out;
		logic nor_gate_out;
		lc3b_word mem_target;
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
	//DECODE-EXECUTE STAGE INTERNAL SIGNAL//
		lc3b_word id_ex_pc_out;
		lc3b_word id_ex_ir_out;
		lc3b_word id_ex_sr1_out;
		lc3b_word id_ex_sr2_out;
		lc3b_word id_ex_cc_out;
		lc3b_reg id_ex_drid_out;
		logic id_ex_v_out;
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
	//EXECUTE-MEMORY STAGE INTERNAL SIGNALS//
		lc3b_offset11 ex_mem_cs_out;
		lc3b_word ex_mem_pc_out;
		lc3b_reg ex_mem_cc_out;					
		lc3b_word ex_mem_alu_result_out;
		lc3b_word ex_mem_ir_out;
		lc3b_reg ex_mem_dr_out;
		lc3b_word ex_mem_address_out;
		logic and1_out;
		logic and2_out;
		logic and3_out; //same as what would be "and4"
		logic we0;
		logic we1;
	//MEMORY STAGE INTERNAL SIGNALS//
		lc3b_word Dcachesplitmux_out;
		lc3b_word Dcachewritemux_out;
		lc3b_word Dcachereadmux_out;
	//MEMORY-WRITEBACK INTERNAL SIGNALS//
		
/*END INTERNAL SIGNALS*/


/*FETCH STAGE COMPONENTS*/
mux3 pcmux 
(
	.sel(pcmux_sel), //Need to bring this from control rom
	.a(pc_plus2_out),
	.b(mem_target), //From MEM_address in MEM STAGE
	.c(),//MEM.TRAP need this signal from MEM STAGE
	.f(pcmux_out)
);

register pc
(
	.clk,
	.load(load_pc),//NEED to bring this from control ROM
	.in(pcmux_out),
	.out(pc_out)
);

plus2 pc_plus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

nor3input #(.width(1)) nor_gate
(
	.a(),//ID.branch_stall
	.b(),//mem_stall
	.c(),//DEP_stall
	.f(nor_gate_out)
);

and2input #(.width(1)) and_gate
(
	.a(i_mem_resp),
	.b(nor_gate_out),
	.f(load_if_id)
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
	.in(imem_rdata),
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
mux2 #(.width(3)) storemux
(
	.sel(storemux_sel), //Need to bring this from control rom
	.a(if_id_ir_out[2:0]),
	.b(if_id_ir_out[11:9]),
	.f(storemux_out)
);

mux2 #(.width(3)) destmux
(
	.sel(destmux_sel), //Need to bring this from control rom
	.a(if_id_ir_out[11:9]),
	.b(3'b111),
	.f(destmux_out)
);

regfile regfile
(
	.clk,
	.in(),//WB.regfile.data	
	.src_a(if_id_ir_out[8:6]),
	.src_b(storemux_out),
	.dest(),//WB.DRID
	.reg_a(sr1_out),
	.reg_b(sr2_out)
);

register #(.width(3)) cc
(
	.clk,
	.load(),//WB.loadCC	
	.in(),//WB.ccdata
	.out(cc_out)
);
//Still need dependency logic//
//Still need branch stall logic//
//Still need control store//
dependencylogic dependencylogic
(
	.sr1_needed(), //NEED to bring in from the control store
	.sr2_needed(), //NEED to bring in from the control store
	.sr1(if_id_ir_out[8:6]),
	.sr2(storemux_out),
	.de_br_op(), //NEED to bring in from the control store
	.ex_dr(id_ex_drid_out),
	.mem_dr(ex_mem_dr_out),
	.wb_dr(mem_wb_dr_out),
	.v_ex_ld_reg(), //Need to get this from the execute stage
	.v_mem_ld_reg(), //Need to get this from the memory stage
	.v_wb_ld_reg(), //Need to get this from the writeback stage
	.v_ex_ld_cc(), //Need to get this from the execute stage
	.v_mem_ld_cc(), //Need to get this from the memory stage
	.v_wb_ld_cc(), //Need to get this from the writeback stage
	.dep_stall(dep_stall)
);

/*END DECODE STAGE COMPONENTS*/

/*DECODE-EXECUTE PIPE COMPONENTS*/
register id_ex_pc
(
	.clk,
	.load(load_id_ex),
	.in(if_id_pc_out),
	.out(id_ex_pc_out)
);

register id_ex_cs
(
	.clk,
	.load(load_id_ex),
	.in(),//Need to take the output of the control store
	.out()//id_ex_cs_out
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
	.sel(),//NEED to get from CONTROL ROM
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
	.sel(),//addr3mux_sel from control store
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
	.sel(), //addr2mux_sel from control store
	.a(16'b0000000000000000),
	.b(sext5_out),
	.c(sext9_out),
	.d(sext11_out),
	.f(addr2mux_out)
);

mux2 addr1mux
(
	.sel(),//addr1mux_sel from control store
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
	.aluop(),//Needs to come from Control Store
   .a(id_ex_sr1_out),
	.b(sr2mux_out),
   .f(alu_out)
);

mux2 aluresultmux
(
	.sel(),//Needs to come from Control Store
	.a(shft_out),
	.b(alu_out),
	.f(aluresultmux_out)
);

mux2 sr2mux
(
	.sel(),//sr2mux_sel from control store
	.a(id_ex_sr2_out),
	.b(sext5_out),
	.f(sr2mux_out)
);
/*END EXECUTE STAGE COMPONENTS*/

/*EXECUTE-MEMORY PIPE COMPONENTS*/
register ex_mem_address
(
	.clk,
	.load(load_ex_mem),
	.in(addr3mux_out),
	.out(ex_mem_address_out)
);

register #(.width(11)) ex_mem_cs
(
	.clk,
	.load(load_ex_mem),
	.in(), //input 11 bits from execute stage
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
	.in(),//input from ex is 3 bits
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
assign mem_trap = dcache_rdata;

zext #(.width(8)) HBzext
(
     .in(dcache_rdata[15:8]),
	 .out(HBzext_out)
);

zext #(.width(8)) LBzext
(
     .in(dcache_rdata[7:0]),
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
    .sel(dcachereadmux_sel), //FROM control ROM
	 .a(dcache_rdata), //Output from the D-Cache on read
	 .b(Dcachesplitmux_out),
	 .f(Dcachereadmux_out)
);

bytefill #(.width(8)) bytefill
(
     .in(ex_mem_alu_result_out[7:0]),
	  .bytefill_sel(ex_mem_address_out[0]),
	 .out(bytefill_out)
);

mux2 #(.width(16)) Dcachewritemux
(
    .sel(dcachewritemux_sel), //FROM control ROM
	 .a(ex_mem_alu_result_out), 
	 .b(bytefill_out),
	 .f(Dcachewritemux_out)
);



    /*Begin DCache Write Enable Logic*/
    and2input and1
    (
	    .x(), //D_CACHE_R/W control signal
	    .y(!ex_mem_address_out[0]),
	    .z(and1_out)

    );
    and2input and2
    (
	    .x(), //D_CACHE_R/W control signal
	    .y(ex_mem_address_out[0]),
	    .z(and2_out)

    );

    and2input and3
    (
	    .x(), //D_CACHE_R/W control signal
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


/*END MEMORY STAGE COMPONENTS*/

/*MEMORY-WRITEBACK PIPE COMPONENTS*/
register mem_wb_address
(
	.clk,
	.load(load_mem_wb),
	.in(mem_address),
	.out(mem_wb_address_out)

);

register mem_wb_data
(
	.clk,
	.load(load_mem_wb),
	.in(Dcachemux_out),//Data from D-Cache
	.out(mem_wb_data_out)
);

register #(.width(4)) mem_wb_cs
(
	.clk,
	.load(load_mem_wb),
	.in(ex_mem_cs_out[10:7]), //cs from mem phase 4 bits
	.out() //from control store

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

 mux4 wb_mux
 (
	.sel(),//wb_mux_sel
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


/*END WRITE BACK STAGE COMPONENTS*/


endmodule : pipelineCPU_datapath
