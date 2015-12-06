import lc3b_types::*;

module alu
(
    input lc3b_aluop aluop,
    input lc3b_word a, b,
    output lc3b_word f
);

always_comb
begin
    case (aluop)
        alu_add: f = a + b;
        alu_and: f = a & b;
        alu_not: f = ~a;
        alu_passa: f = a;
		  alu_passb: f = b;
        alu_sll: f = a << b;
        alu_srl: f = a >> b;
        alu_sra: f = $signed(a) >>> b;
		  
		  //LC3X
		  alu_sub: f = a -b;
		  alu_or: f = a | b;
		  alu_xor: f = a^b;
		  alu_xnor: f = ~(a^b);
		  alu_nor: f = ~(a|b);
		  alu_nand: f = !(a & b);
		  alu_mult: f = a*b;
		  alu_div: f = a/b;
		  
		  
        default: $display("Unknown aluop");
    endcase
end

endmodule : alu
