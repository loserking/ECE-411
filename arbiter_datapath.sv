/* The datapath for the arbiter*/


import lc3b_types::*;

module arbiter_datapath
(
    input clk,
	 /*inputs from cpu*/
    input logic i_mem_read,
	 input logic i_mem_write,
	 input lc3b_word i_mem_address,
	 input cache_line i_mem_wdata,
	 input logic d_mem_read,
	 input logic d_mem_write,
	 input lc3b_word d_mem_address,
	 input cache_line d_mem_wdata, 
	 input cache_line l2_mem_rdata,
	 input logic l2_mem_resp,
	 input logic[1:0] d_mem_byte_enable,
	 input logic[1:0] i_mem_byte_enable,
	 //From arbiter control
	 input logic readsignalmux_sel,
	 input logic writesignalmux_sel,
	 input logic memaddressmux_sel,
	 input logic memwdatamux_sel,
	 input logic memrdatademux_sel,
	 input logic memrespmux_sel,
	 input logic byteenablemux_sel,
	 
	 output logic arbiter_i_mem_resp,
	 output logic arbiter_d_mem_resp,
	 output cache_line arbiter_d_mem_rdata,
	 output cache_line arbiter_i_mem_rdata,
	 output cache_line arbiter_mem_wdata,
	 output logic arbiter_mem_write,
	 output logic arbiter_mem_read,
	 output logic[1:0] arbiter_pmem_byte_enable,
	 output lc3b_word arbiter_mem_address
);


mux2 #(.width(1)) readsignalmux
(
    .sel(readsignalmux_sel),
	 .a(d_mem_read),
	 .b(i_mem_read),
	 .f(arbiter_mem_read)
);

mux2 #(.width(2)) byteenablemux
(
	.sel(byteenablemux_sel),
	.a(d_mem_byte_enable),
	.b(i_mem_byte_enable),
	.f(arbiter_pmem_byte_enable)
);

mux2 #(.width(1)) writesignalmux
(
    .sel(writesignalmux_sel),
	 .a(d_mem_write),
	 .b(i_mem_write),
	 .f(arbiter_mem_write)
);

mux2 memaddressmux
(
	.sel(memaddressmux_sel),
	.a(d_mem_address),
	.b(i_mem_address),
	.f(arbiter_mem_address)
);

mux2 #(.width(128)) memwdatamux
(
	.sel(memwdatamux_sel),
	.a(d_mem_wdata),
	.b(i_mem_wdata),
	.f(arbiter_mem_wdata)
);

demux2_1 #(.width(128)) memrdatademux
(
	.sel(memrdatademux_sel),
	.in(l2_mem_rdata),
	.outone(arbiter_d_mem_rdata),
	.outtwo(arbiter_i_mem_rdata)
);

demux2_1 #(.width(1)) memrespmux
(
	.sel(memrespmux_sel),
	.in(l2_mem_resp),
	.outone(arbiter_d_mem_resp),
	.outtwo(arbiter_i_mem_resp)
);


endmodule: arbiter_datapath