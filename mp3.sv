import lc3b_types::*;

module mp3
(
    input clk
);

/* Instantiate MP 3 top level blocks here */
pipelineCPU_datapath cpu_datapath
(
	.clk,
	.i_mem_address(),
	.i_mem_wdata(),
	.i_mem_read(),
	.i_mem_write(),
	.i_mem_byte_enable(),
	.i_mem_rdata(),
	.i_mem_resp(),
	.d_mem_address(),
	.d_mem_wdata(),
	.d_mem_read(),
	.d_mem_write(),
	.d_mem_byte_enable(),
	.d_mem_rdata(),
	.d_mem_resp()
);



endmodule : mp3
