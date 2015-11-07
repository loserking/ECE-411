/* cache design top level -- contains the cache controller and the cache datapath */
import lc3b_types::*;

module l1dcache
(
    input clk,
	 input cache_line pmem_rdata,
	 input logic pmem_resp,
	 input lc3b_mem_wmask mem_byte_enable,
	 input lc3b_word mem_address,
	 input lc3b_word mem_wdata,
	 input mem_read,
    input mem_write,
	 input dcache_enable,


    /* Memory signals */
    output mem_resp,
    output lc3b_word mem_rdata,
	 output logic hit,


	 output logic pmem_read,
	 output logic pmem_write,
	 output lc3b_word pmem_address,
	 output cache_line pmem_wdata
	 
);


/*internal signals*/

logic lru_out;
logic data0write;
logic data1write;
logic valid0write;
logic valid1write;
logic tag0write;
logic tag1write;
logic lru_in;
logic way0and_out;
logic lru_write;
logic dirtymux_out;
logic stbwritemux_sel;
logic rwmux_sel;
logic dirty0write;
logic dirty1write;
logic dirty0_in;
logic dirty1_in;
logic pmemmux_sel;


dcache_control dcache_control
(
	 .clk,
    .mem_address(mem_address),
	 .mem_byte_enable(mem_byte_enable),
	 .mem_write(mem_write),
	 .mem_read(mem_read),
	 .mem_wdata(mem_wdata),
	 .lru_out(lru_out),
	 .lru_in(lru_in),
	 .way0and_out(way0and_out),
	 .lru_write(lru_write),
	 .dcache_enable(dcache_enable),
	 
     
     /* Datapath controls */
    .pmem_rdata(pmem_rdata),
	 .pmem_resp(pmem_resp),
	 .dirtymux_out(dirtymux_out),
	 .hit(hit),
	 
	 .pmemmux_sel(pmemmux_sel),
	 .rwmux_sel(rwmux_sel),
	 .stbwritemux_sel(stbwritemux_sel),
	 .mem_resp(mem_resp),
    .pmem_read(pmem_read),
	 .data0write(data0write),
	 .data1write(data1write),
	 .tag0write(tag0write), 
	 .tag1write(tag1write),
	 .valid0write(valid0write),
	 .valid1write(valid1write),
	 .dirty0write(dirty0write),
	 .dirty1write(dirty1write),
	 .dirty0_in(dirty0_in),
	 .dirty1_in(dirty1_in),
    .pmem_write(pmem_write)
);

cache_datapath  cache_datapath
(
    .clk,
	 /*inputs from cpu*/
	 .mem_address(mem_address),
	 .data0write(data0write),
	 .data1write(data1write),
	 .tag0write(tag0write),
	 .tag1write(tag1write),
	 .valid0write(valid0write),
	 .valid1write(valid1write),
	 .dirty0write(dirty0write),
	 .dirty1write(dirty1write),
	 .dirty0_in(dirty0_in),
	 .dirty1_in(dirty1_in),
	 .pmem_rdata(pmem_rdata),
	 .mem_wdata(mem_wdata),
	 .mem_rdata(mem_rdata),
	 .mem_byte_enable(mem_byte_enable),
	 .lru_in(lru_in),
	 .lru_write(lru_write),
	 .way0and_out(way0and_out),
	 .rwmux_sel(rwmux_sel),
	 .stbwritemux_sel(stbwritemux_sel),
	 .pmemmux_sel(pmemmux_sel),

    .hit(hit),
	 .dirtymux_out(dirtymux_out),
	 .lru_out(lru_out),
	 .pmem_address(pmem_address),
	 .pmem_wdata(pmem_wdata)
);


endmodule : l1dcache

