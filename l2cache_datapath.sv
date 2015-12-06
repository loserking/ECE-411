/* cache datapath -- contains the data array, valid array, dirty array, tag array, LRU array, comparators, muxes, logic gates, and so on. */

import lc3b_types::*;

module l2cache_datapath
(
    input clk,
	 /*inputs from cpu*/
	 input lc3b_word mem_address,
	 input logic data0write, data1write,
	 input logic tag0write, tag1write,
	 input logic dirty0write, dirty1write,
	 input logic dirty0_in, dirty1_in,
	 input logic valid0write, valid1write,
	 input logic valid2write, valid3write,
	 input logic dirty2_in, dirty3_in,
	 input logic dirty2write, dirty3write,
	 input logic tag2write, tag3write,
	 input logic data2write, data3write,
	 input logic pseudolru_write,
	 input [1:0] mem_byte_enable,
	 input logic rwmux_sel,
	 input logic stbwritemux_sel,
	 input cache_line pmem_rdata,
	 input cache_line l2_mem_wdata,   //Needs to be cache_line l2_mem_wdata
	 input logic pmemmux_sel,
	 output cache_line l2_mem_rdata,  //Needs to be cache_line l2_mem_rdata	

    output logic hit,
	 output logic [1:0] pseudolru_out,
	 output logic way0and_out,
	 output logic dirtymux_out,
	 output cache_line pmem_wdata,
	 output lc3b_word pmem_address
);

tag_size tag;
lc3b_c_index index;
lc3b_c_index offset;
logic offsetlast;
logic valid;

/* declare internal signals */
assign tag = mem_address[15:7];
assign index = mem_address[6:4];
assign offset = mem_address[3:1];
assign offsetlast = mem_address[0];
assign valid = 1'b1;

/*way 3 signals*/
tag_size tag3_out;
logic way3tag_comp_out;
logic valid3_out;
logic way3and_out;
logic dirty3_out;
cache_line data3_out;



/*way 2 signals*/
tag_size tag2_out;
logic way2tag_comp_out;
logic valid2_out;
logic way2and_out;
logic dirty2_out;
cache_line data2_out;

/*way 1 signals */
logic valid1_out;
logic dirty1_out;
tag_size tag1_out;
cache_line data1_out;

logic way1tag_comp_out;
logic way1and_out;

/*way 0 signals*/
logic valid0_out;
logic dirty0_out;
tag_size tag0_out;
cache_line data0_out;


logic way0tag_comp_out;

/*combined way  signals*/
cache_line datamux_out;
logic lrumux_out;
lc3b_byte memrdatasplitmux_out;
lc3b_byte memwdatasplitmux_out;
lc3b_word stbwritemux_out;
lc3b_word splitconcat_out;
cache_line cache_lineconcat_out;
cache_line rwmux_out;
tag_size tagmux_out;

/*combined way logic*/
or4input hitcheck
(
	.x(way0and_out),
	.y(way1and_out),
	.q(way2and_out),
	.r(way3and_out),
	.z(hit)
);


/*array #(.width(1)) lru
(
	.clk,
	.write(lru_write),
	.index(index),
	.datain(lru_in),
	.dataout(lru_out)
);*/

pseudolru pseudolru
(
	.clk,
	.pseudolru_write(pseudolru_write),
	.valid0out(valid0_out),
	.valid1out(valid1_out),
	.valid2out(valid2_out),
	.valid3out(valid3_out),
	.lru(pseudolru_out)
);

mux4 #(.width(128)) evictdatamux
(
    .sel(pseudolru_out),
	 .a(data0_out),
	 .b(data1_out),
	 .c(data2_out),
	 .d(data3_out),
	 .f(pmem_wdata)
);

mux4 #(.width(9)) tagmux
(
    .sel(pseudolru_out),
	 .a(tag0_out),
	 .b(tag1_out),
	 .c(tag2_out),
	 .d(tag3_out),
	 .f(tagmux_out)
);

mux2 #(.width(16)) pmemmux
(
    .sel(pmemmux_sel),
	 .a(mem_address),
	 .b({tagmux_out,index,4'b0000}),
	 .f(pmem_address)
);

mux4 #(.width(1)) dirtymux
(
    .sel(pseudolru_out),
	 .a(dirty0_out),
	 .b(dirty1_out),
	 .c(dirty2_out),
	 .d(dirty3_out),
	 .f(dirtymux_out)
);
/*
mux8 memrdatamux
(
	.sel(offset),
	.a(datamux_out[15:0]),
	.b(datamux_out[31:16]),
	.c(datamux_out[47:32]),
	.d(datamux_out[63:48]),
	.e(datamux_out[79:64]),
	.f(datamux_out[95:80]),
	.g(datamux_out[111:96]),
	.h(datamux_out[127:112]),
	.out(mem_rdata)
);
*/ 
//Mem RDATA mux not needed for L2Cache

assign l2_mem_rdata = datamux_out;

/*
sixteenonetwentyeightconcat cache_lineconcat
(
	.read_data(datamux_out),
	.write_data(stbwritemux_out),
	.sel(offset),
	.out(cache_lineconcat_out)
);
*/
//Don't think this is used by l2cache
logic [1:0] datamux_sel;

always_comb
begin
	if(way0and_out)
		datamux_sel = 2'b00;
	else if(way1and_out)
		datamux_sel = 2'b01;
	else if(way2and_out)
		datamux_sel = 2'b10;
	else if(way3and_out)
		datamux_sel = 2'b11;
	else
		datamux_sel = 2'b00;
end

mux4 #(.width(128)) datamux
(
    .sel(datamux_sel),
	 .a(data0_out),
	 .b(data1_out),
	 .c(data2_out),
	 .d(data3_out),
	 .f(datamux_out)
);

mux2 #(.width(128)) rwmux
(
    .sel(rwmux_sel),
	 .a(pmem_rdata),
	 .b(l2_mem_wdata),
	 .f(rwmux_out)
);

/*
mux2 #(.width(8)) memwdatasplitmux
(
    .sel(mem_byte_enable[1]),
	 .a(mem_wdata[7:0]),
	 .b(mem_wdata[15:8]),
	 .f(memwdatasplitmux_out)
);

mux2 #(.width(8)) memrdatasplitmux
(
    .sel(mem_byte_enable[0]),
	 .a(mem_rdata[7:0]),
	 .b(mem_rdata[15:8]),
	 .f(memrdatasplitmux_out)
);
*/
//Don't think this is needed at the L2 Level

/*
mux2 #(.width(16)) stbwritemux
(
    .sel(stbwritemux_sel),
	 .a(mem_wdata),
	 .b(splitconcat_out),
	 .f(stbwritemux_out)
);

eighteightconcat splitconcat
(
	.a(memrdatasplitmux_out),
	.b(memwdatasplitmux_out),
	.sel(mem_byte_enable[1]),
	.out(splitconcat_out)

);
*/
//more unnecessary components for l2 cache

/* Way 3 logic*/
tag_comp way3tag_comp
(
	.cache_in(tag),
	.mem_address_in(tag3_out),
	.out(way3tag_comp_out)
);

and2input way3and
(
	.x(valid3_out),
	.y(way3tag_comp_out),
	.z(way3and_out)
);

/*Way 3 arrays begin*/
array #(.width(1)) valid3
(
	.clk,
	.write(valid3write),
	.index(index),
	.datain(valid),
	.dataout(valid3_out)
);

array #(.width(1)) dirty3
(
	.clk,
	.write(dirty3write),
	.index(index),
	.datain(dirty3_in),
	.dataout(dirty3_out)
);


array #(.width(9)) tag3
(
	.clk,
	.write(tag3write),
	.index(index),
	.datain(tag),
	.dataout(tag3_out)
);

array data3
(
	.clk,
   .write(data3write),
   .index(index),
   .datain(rwmux_out),
   .dataout(data3_out)
);


/* Way 2 logic*/
tag_comp way2tag_comp
(
	.cache_in(tag),
	.mem_address_in(tag2_out),
	.out(way2tag_comp_out)
);

and2input way2and
(
	.x(valid2_out),
	.y(way2tag_comp_out),
	.z(way2and_out)
);

/*Way 2 arrays begin*/
array #(.width(1)) valid2
(
	.clk,
	.write(valid2write),
	.index(index),
	.datain(valid),
	.dataout(valid2_out)
);

array #(.width(1)) dirty2
(
	.clk,
	.write(dirty2write),
	.index(index),
	.datain(dirty2_in),
	.dataout(dirty2_out)
);


array #(.width(9)) tag2
(
	.clk,
	.write(tag2write),
	.index(index),
	.datain(tag),
	.dataout(tag2_out)
);

array data2
(
	.clk,
   .write(data2write),
   .index(index),
   .datain(rwmux_out),
   .dataout(data2_out)
);


/* Way 1 logic*/
tag_comp way1tag_comp
(
	.cache_in(tag),
	.mem_address_in(tag1_out),
	.out(way1tag_comp_out)
);

and2input way1and
(
	.x(valid1_out),
	.y(way1tag_comp_out),
	.z(way1and_out)
);

/*Way 1 arrays begin*/
array #(.width(1)) valid1
(
	.clk,
	.write(valid1write),
	.index(index),
	.datain(valid),
	.dataout(valid1_out)
);

array #(.width(1)) dirty1
(
	.clk,
	.write(dirty1write),
	.index(index),
	.datain(dirty1_in),
	.dataout(dirty1_out)
);


array #(.width(9)) tag1
(
	.clk,
	.write(tag1write),
	.index(index),
	.datain(tag),
	.dataout(tag1_out)
);

array data1
(
	.clk,
   .write(data1write),
   .index(index),
   .datain(rwmux_out),
   .dataout(data1_out)
);


/*Way 0 logic*/
tag_comp way0tag_comp
(
	.cache_in(tag),
	.mem_address_in(tag0_out),
	.out(way0tag_comp_out)
);

and2input way0and
(
	.x(valid0_out),
	.y(way0tag_comp_out),
	.z(way0and_out)
);


/*Way 0 arrays begin */
array #(.width(1)) valid0
(
	.clk,
	.write(valid0write),
	.index(index),
	.datain(valid),
	.dataout(valid0_out)
);

array #(.width(1)) dirty0
(
	.clk,
	.write(dirty0write),
	.index(index),
	.datain(dirty0_in),
	.dataout(dirty0_out)
);


array #(.width(9)) tag0
(
	.clk,
	.write(tag0write),
	.index(index),
	.datain(tag),
	.dataout(tag0_out)
);

array data0
(
	.clk,
   .write(data0write),
   .index(index),
   .datain(rwmux_out),
   .dataout(data0_out)
);


endmodule : l2cache_datapath
