/*the datapath that contains everything for the pipeline CPU*/
module pipelineCPU_datapath(
	input clk
	
);

/*INTERNAL SIGNALS*/
lc3b_word pcmux_out;	
lc3b_word pc_out;
lc3b_word pc_plus2_out;
/*END INTERNAL SIGNALS*/


/*FETCH STAGE COMPONENTS*/
mux3 pcmux 
(
	.sel(pcmux_sel), //Need to bring this from control rom
	.a(pc_plus2_out),
	.b(),//MEM.TARGET need this signal from MEM STAGE
	.c(),//MEM.TRAP need this signal from MEM STAGE
	.f(pcmux_out),
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
/*END FETCH STAGE COMPONENTS*/

/*FETCH-DECODE PIPE COMPONENTS*/

/*END FETCH-DECODE PIPE COMPONENTS*/

/*DECODE STAGE COMPONENTS*/


/*END DECODE STAGE COMPONENTS*/

/*DECODE-EXECUTE PIPE COMPONENTS*/

/*END DECODE-EXECUTE PIPE COMPONENTS*/


/*EXECUTE STAGE COMPONENTS*/


/*END EXECUTE STAGE COMPONENTS*/

/*EXECUTE-MEMORY PIPE COMPONENTS*/

/*END EXECUTE-MEMORY PIPE COMPONENTS*/


/*MEMORY STAGE COMPONENTS*/

/*END MEMORY STAGE COMPONENTS*/

/*MEMORY-WRITEBACK PIPE COMPONENTS*/

/*END MEMORY-WRITEBACK PIPE COMPONENTS*/

/*WRITE BACK STAGE COMPONENTS*/

/*END WRITE BACK STAGE COMPONENTS*/


endmodule : pipelineCPU_datapath