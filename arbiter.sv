/*top level module for the arbiter*/
import lc3b_types::*;

module arbiter
(
    input clk,
    input logic i_mem_read,
	 input logic i_mem_write,
	 input lc3b_word i_mem_address,
	 input cache_line i_mem_wdata,
	 input logic d_mem_read,
	 input logic d_mem_write,
	 input lc3b_word d_mem_address,
	 input cache_line d_mem_wdata, 
	 input cache_line l2_mem_rdata,
	 input l2_mem_resp,
	 input logic[1:0] d_mem_byte_enable,
	 input logic[1:0] i_mem_byte_enable,
	 input logic l2hit,
	 
	 output logic arbiter_i_mem_resp,
	 output logic arbiter_d_mem_resp,
	 
	 output cache_line arbiter_mem_wdata,
	 output logic arbiter_mem_write,
	 output logic arbiter_mem_read,
	 output lc3b_word arbiter_mem_address,
	 output cache_line arbiter_d_mem_rdata,
	 output logic[1:0] arbiter_pmem_byte_enable,
	 output cache_line arbiter_i_mem_rdata
	 
);


/*internal signals*/
logic readsignalmux_sel;
logic writesignalmux_sel;
logic memaddressmux_sel;
logic memwdatamux_sel;
logic memrdatademux_sel;
logic memrespmux_sel;
logic byteenablemux_sel;


arbiter_control arbiter_control
(
	 .clk,
    .i_mem_read(i_mem_read),
	 .i_mem_write(i_mem_write),
	 .d_mem_read(d_mem_read),
	 .d_mem_write(d_mem_write),
	 .l2_mem_resp(l2_mem_resp),
	 .l2hit(l2hit),
	 
	 //To arbiter datapath
	 .readsignalmux_sel(readsignalmux_sel),
	 .writesignalmux_sel(writesignalmux_sel),
	 .memaddressmux_sel(memaddressmux_sel),
	 .memwdatamux_sel(memwdatamux_sel),
	 .memrdatademux_sel(memrdatademux_sel),
	 .byteenablemux_sel(byteenablemux_sel),
	 .memrespmux_sel(memrespmux_sel)
);

arbiter_datapath arbiter_datapath
(
    .clk,
	 /*inputs from cpu*/
    .i_mem_read(i_mem_read),
	 .i_mem_write(i_mem_write),
	 .i_mem_address(i_mem_address),
	 .i_mem_wdata(i_mem_wdata),
	 .d_mem_read(d_mem_read),
	 .d_mem_write(d_mem_write),
	 .d_mem_address(d_mem_address),
	 .d_mem_wdata(d_mem_wdata), 
	 .l2_mem_rdata(l2_mem_rdata),
	 .l2_mem_resp(l2_mem_resp),
	 .d_mem_byte_enable(d_mem_byte_enable),
	 .i_mem_byte_enable(i_mem_byte_enable),
	 //From arbiter control
	 .readsignalmux_sel(readsignalmux_sel),
	 .writesignalmux_sel(writesignalmux_sel),
	 .memaddressmux_sel(memaddressmux_sel),
	 .memwdatamux_sel(memwdatamux_sel),
	 .memrdatademux_sel(memrdatademux_sel),
	 .memrespmux_sel(memrespmux_sel),
	 .byteenablemux_sel(byteenablemux_sel),
	 
	 .arbiter_i_mem_resp(arbiter_i_mem_resp),
	 .arbiter_d_mem_resp(arbiter_d_mem_resp),
	 .arbiter_d_mem_rdata(arbiter_d_mem_rdata),
	 .arbiter_i_mem_rdata(arbiter_i_mem_rdata),
	 .arbiter_mem_wdata(arbiter_mem_wdata),
	 .arbiter_mem_write(arbiter_mem_write),
	 .arbiter_mem_read(arbiter_mem_read),
	 .arbiter_pmem_byte_enable(arbiter_pmem_byte_enable),
	 .arbiter_mem_address(arbiter_mem_address)
);


endmodule : arbiter

