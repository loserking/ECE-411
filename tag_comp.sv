/* a module for comparing the tag in mem_address to the tag in the cache specified by index*/
module tag_comp
(
		input [8:0] cache_in,
      input [8:0] mem_address_in,
		output logic out
);

always_comb
begin
	if(cache_in == mem_address_in)
		out = 1;
	else
		out = 0;
end

endmodule : tag_comp
