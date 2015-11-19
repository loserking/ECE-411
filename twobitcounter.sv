/*A two bit counter module used for LDI/STI*/

module twobitcounter
(
	input logic clk,
	input logic d_mem_resp,
	input logic ldi_op,
	input logic sti_op,
	input logic dcache_stall,
	output logic [1:0] count
);


logic [1:0] data;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 2'b00;
end

always_ff @(posedge clk)
begin
	if((d_mem_resp) &&(ldi_op || sti_op)&&(!dcache_stall))
		data++;
	else if((ldi_op || sti_op) &&(dcache_stall))
		data = data;
	else
		data = 0;
end 

always_comb
begin
	count = data;
end

endmodule: twobitcounter