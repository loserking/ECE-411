module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;


logic arbiter_mem_read;
logic arbiter_mem_write;
logic [15:0] arbiter_mem_address;
logic [1:0] pmem_byte_enable;
logic [127:0] arbiter_mem_wdata;
logic l2_mem_resp;
logic [127:0] l2_mem_rdata;


/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
	 .clk,
	 .l2_mem_resp(l2_mem_resp),
	 .l2_mem_rdata(l2_mem_rdata),
	 .arbiter_mem_read(arbiter_mem_read),
	 .arbiter_mem_write(arbiter_mem_write),
	 .pmem_byte_enable(pmem_byte_enable),
	 .arbiter_mem_wdata(arbiter_mem_wdata),
	 .arbiter_mem_address(arbiter_mem_address)
);

physical_memory pmem
(
	 .clk,
    .read(arbiter_mem_read),
    .write(arbiter_mem_write),
    .address(arbiter_mem_address),
    .wdata(arbiter_mem_wdata),
    .resp(l2_mem_resp),
    .rdata(l2_mem_rdata)
);

endmodule : mp3_tb
