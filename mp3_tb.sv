module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;


logic pmem_mem_resp;
logic [127:0] pmem_mem_rdata;
logic pmem_mem_read;
logic pmem_mem_write;
logic [1:0] pmem_byte_enable;
logic [127:0] pmem_mem_wdata;
logic [15:0] pmem_mem_address;


/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
    .clk,
	 .pmem_mem_resp(pmem_mem_resp),
	 .pmem_mem_rdata(pmem_mem_rdata),
	 .pmem_mem_read(pmem_mem_read),
	 .pmem_mem_write(pmem_mem_write),
	 .pmem_byte_enable(pmem_byte_enable),
	 .pmem_mem_wdata(pmem_mem_wdata),
	 .pmem_mem_address(pmem_mem_address)
);

physical_memory pmem
(
	 .clk,
    .read(pmem_mem_read),
    .write(pmem_mem_write),
    .address(pmem_mem_address),
    .wdata(pmem_mem_wdata),
    .resp(pmem_mem_resp),
    .rdata(pmem_mem_rdata)
);

endmodule : mp3_tb
