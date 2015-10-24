import lc3b_types::*;

module mp3
(
    input clk,
	 input lc3b_word i_mem_rdata,
	 input logic i_mem_resp,
	 input lc3b_word d_mem_rdata,
	 input logic d_mem_resp,
	 
	 output lc3b_word i_mem_address,
	 output logic [1:0] i_mem_byte_enable,
	 output logic i_mem_read,
	 output logic i_mem_write,
	 output lc3b_word i_mem_wdata,
	 output lc3b_word d_mem_address,
	 output logic [1:0] d_mem_byte_enable,
	 output logic d_mem_write,
	 output logic d_mem_read,
	 output lc3b_word d_mem_wdata
	 
);

/* Instantiate MP 3 top level blocks here */
cpu_datapath cpu_datapath
(
	.clk,
	.i_mem_address(i_mem_address),
	.i_mem_wdata(i_mem_wdata),
	.i_mem_read(i_mem_read),
	.i_mem_write(i_mem_write),
	.i_mem_byte_enable(i_mem_byte_enable),
	.i_mem_rdata(i_mem_rdata),
	.i_mem_resp(i_mem_resp),
	.d_mem_address(d_mem_address),
	.d_mem_wdata(d_mem_wdata),
	.d_mem_read(d_mem_read),
	.d_mem_write(d_mem_write),
	.d_mem_byte_enable(d_mem_byte_enable),
	.d_mem_rdata(d_mem_rdata),
	.d_mem_resp(d_mem_resp)
);



endmodule : mp3
