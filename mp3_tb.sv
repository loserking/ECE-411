module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;

logic i_mem_resp;
logic i_mem_read;
logic i_mem_write;
logic [1:0] i_mem_byte_enable;
logic [15:0] i_mem_address;
logic [15:0] i_mem_rdata;
logic [15:0] i_mem_wdata;
logic d_mem_resp;
logic d_mem_read;
logic d_mem_write;
logic [1:0] d_mem_byte_enable;
logic [15:0] d_mem_address;
logic [15:0] d_mem_rdata;
logic [15:0] d_mem_wdata;


/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

mp3 dut
(
	.clk,
	.i_mem_read(i_mem_read),
	.i_mem_write(i_mem_write),
	.i_mem_byte_enable(i_mem_byte_enable),
	.i_mem_address(i_mem_address),
	.i_mem_rdata(i_mem_rdata),
	.i_mem_wdata(i_mem_wdata),
	.i_mem_resp(i_mem_resp),
	.d_mem_read(d_mem_read),
	.d_mem_write(d_mem_write),
	.d_mem_byte_enable(d_mem_byte_enable),
	.d_mem_address(d_mem_address),
	.d_mem_rdata(d_mem_rdata),
	.d_mem_wdata(d_mem_wdata),
	.d_mem_resp(d_mem_resp)
);


magic_memory_dp magic_memory_dp
(
	.clk,

    /* Port A */
    .read_a(i_mem_read),
    .write_a(i_mem_write),
    .wmask_a(i_mem_byte_enable),
    .address_a(i_mem_address),
    .wdata_a(i_mem_wdata),
    .resp_a(i_mem_resp),
    .rdata_a(i_mem_rdata),

    /* Port B */
    .read_b(d_mem_read),
    .write_b(d_mem_write),
    .wmask_b(d_mem_byte_enable),
    .address_b(d_mem_address),
    .wdata_b(d_mem_wdata),
    .resp_b(d_mem_resp),
    .rdata_b(d_mem_rdata)

);

endmodule : mp3_tb
