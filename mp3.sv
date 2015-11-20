import lc3b_types::*;

module mp3
(
    input clk,
	 input logic pmem_mem_resp,
	 input cache_line pmem_mem_rdata,
	 output logic pmem_mem_read,
	 output logic pmem_mem_write,
	 output logic [1:0] pmem_byte_enable,
	 output cache_line pmem_mem_wdata,
	 output lc3b_word pmem_mem_address
	 
);
/*Begin internal signals*/
	/*CPU internal signals*/
		lc3b_word i_mem_address;
		lc3b_word i_mem_wdata;
		logic i_mem_read;
		logic i_mem_write;
		logic [1:0] i_mem_byte_enable;
		lc3b_word i_mem_rdata;
		logic i_mem_resp;
		
		lc3b_word d_mem_address;
		lc3b_word d_mem_wdata;
		logic d_mem_read;
		logic d_mem_write;
		logic [1:0] d_mem_byte_enable;
		lc3b_word d_mem_rdata;
		logic d_mem_resp;
		logic dcache_enable;
	/*L1 I cache internal signals*/
		lc3b_word i_pmem_address;
		cache_line i_pmem_wdata;
		logic i_pmem_read;
		logic i_pmem_write;
		logic [1:0] i_pmem_byte_enable;
		cache_line i_pmem_rdata;
		logic i_pmem_resp;
		logic br_taken;
		logic idle_state;
	/*L1 D cache internal signals*/
		lc3b_word d_pmem_address;
		cache_line d_pmem_wdata;
		logic d_pmem_read;
		logic d_pmem_write;
		logic [1:0] d_pmem_byte_enable;
		cache_line d_pmem_rdata;
		logic d_pmem_resp;
		logic dcache_hit;
	/*Arbiter Interal Signals*/
		cache_line arbiter_i_mem_rdata;
		cache_line arbiter_d_mem_rdata;
		logic arbiter_i_mem_resp;
		logic arbiter_d_mem_resp;
		cache_line arbiter_mem_wdata;
		logic arbiter_mem_write;
		logic arbiter_mem_read;
		lc3b_word arbiter_mem_address;
		logic [1:0] arbiter_pmem_byte_enable;
	/*L2 Cache Internal Signals*/
		cache_line l2_mem_rdata;
		logic l2_mem_resp;
		logic l2hit;

assign pmem_byte_enable = arbiter_pmem_byte_enable;
/*End Internal Signals*/
/*Begin CPU datapath components */
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
	.dcache_enable(dcache_enable),
	.d_mem_resp(d_mem_resp),
	.dcache_hit(dcache_hit),
	.br_taken(br_taken),
	.idle_state(idle_state)
);
/*End CPU datapath components*/

/*Begin L1 I-Cache Components*/

l1icache l1icache
(

    .clk,
    .mem_address(i_mem_address),
	 .mem_write(i_mem_write),
	 .mem_wdata(i_mem_wdata),
	 .mem_byte_enable(i_mem_byte_enable),
	 .mem_read(i_mem_read),
	 
    .br_taken(br_taken),
 
    .pmem_rdata(arbiter_i_mem_rdata),
	 .pmem_resp(arbiter_i_mem_resp),

	 .mem_rdata(i_mem_rdata),
	 .mem_resp(i_mem_resp),
    .pmem_read(i_pmem_read),
    .pmem_write(i_pmem_write),
	 .pmem_address(i_pmem_address),
	 .pmem_wdata(i_pmem_wdata),
	 .idle_state(idle_state)
);

/*End L1 I-Cache Components*/

/*Begin L1 D-Cache Components*/
l1dcache l1dcache
(

    .clk,
    .mem_address(d_mem_address),
	 .mem_write(d_mem_write),
	 .mem_wdata(d_mem_wdata),
	 .mem_byte_enable(d_mem_byte_enable),
	 .mem_read(d_mem_read),
	 .dcache_enable(dcache_enable),
	 
     

    .pmem_rdata(arbiter_d_mem_rdata),
	 .pmem_resp(arbiter_d_mem_resp),

	 .mem_rdata(d_mem_rdata),
	 .hit(dcache_hit),
	 .mem_resp(d_mem_resp),
    .pmem_read(d_pmem_read),
    .pmem_write(d_pmem_write),
	 .pmem_address(d_pmem_address),
	 .pmem_wdata(d_pmem_wdata)
);
/*End L1 D-Cache Components*/

/*Begin Arbiter Components*/
arbiter arbiter
(
	 .clk,
    .i_mem_read(i_pmem_read),
	 .i_mem_write(i_pmem_write),
	 .i_mem_address(i_pmem_address),
	 .i_mem_wdata(i_pmem_wdata),
	 .d_mem_read(d_pmem_read),
	 .d_mem_write(d_pmem_write),
	 .d_mem_address(d_pmem_address),
	 .d_mem_wdata(d_pmem_wdata), 
	 .l2_mem_rdata(l2_mem_rdata),
	 .l2_mem_resp(l2_mem_resp),
	 .l2hit(l2hit),
	 .d_mem_byte_enable(d_mem_byte_enable),
	 .i_mem_byte_enable(i_mem_byte_enable),
	 .arbiter_i_mem_resp(arbiter_i_mem_resp),
	 .arbiter_d_mem_resp(arbiter_d_mem_resp),
	 
	 .arbiter_mem_wdata(arbiter_mem_wdata),
	 .arbiter_mem_write(arbiter_mem_write),
	 .arbiter_mem_read(arbiter_mem_read),
	 .arbiter_mem_address(arbiter_mem_address),
	 .arbiter_d_mem_rdata(arbiter_d_mem_rdata),
	 .arbiter_i_mem_rdata(arbiter_i_mem_rdata),
	 .arbiter_pmem_byte_enable(arbiter_pmem_byte_enable)
);
/*End Arbiter Components*/
l2cache l2cache
(
    .clk,
	 .pmem_rdata(pmem_mem_rdata),
	 .pmem_resp(pmem_mem_resp),
	 .l2_mem_byte_enable(arbiter_pmem_byte_enable),
	 .l2_mem_address(arbiter_mem_address),
	 .l2_mem_wdata(arbiter_mem_wdata), //cache_line size for l2
	 .l2_mem_read(arbiter_mem_read),
    .l2_mem_write(arbiter_mem_write),


    /* Memory signals */
    .l2_mem_resp(l2_mem_resp),
    .l2_mem_rdata(l2_mem_rdata),  //cache line size for l2


	 .l2hit(l2hit),
	 .pmem_read(pmem_mem_read),
	 .pmem_write(pmem_mem_write),
	 .pmem_address(pmem_mem_address),
	 .pmem_wdata(pmem_mem_wdata)
	 
);

/*Begin L2Cache Components*/


/*End L2Cache Components*/
endmodule : mp3
