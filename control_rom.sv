/*the control rom module that holds all the control signals for the pipelined processor*/

import lc3b_types::*;

module control_rom
(
    input lc3b_opcode opcode,
    input logic ir11,
    input logic ir5,
	 input lc3b_word pc,
    output lc3b_control_word ctrl
);

always_comb
begin 

    /*Default value assignments --- make sure you do one for each signal or it will tell you to use blocking assignments*/
    ctrl.opcode = opcode;
	 ctrl.aluop = alu_passa;
	 ctrl.addr1mux_sel = 1'b0;
	 ctrl.addr2mux_sel = 2'b00;
	 ctrl.br_op = 1'b0;
	 ctrl.lshf = 1'b0;
	 ctrl.sr2mux_sel = 1'b0;
	 ctrl.dcacheR = 1'b0;
	 ctrl.dcacheW = 1'b0;
	 ctrl.wbmux_sel = 2'b00;
    ctrl.load_cc = 1'b0;
    ctrl.load_reg = 1'b0;
    ctrl.storemux_sel = 1'b0;
	 ctrl.pc = pc;
	 ctrl.dcache_enable = 1'b0;

    /*Assign control signals based on opcode */
    case(opcode)
        op_add: 
        begin 
            ctrl.aluop = alu_add;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				if(ir5)
				begin
					ctrl.sr2mux_sel = 1;
				end
        end

        op_and: 
        begin
            ctrl.aluop = alu_and;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				if(ir5)
				begin
					ctrl.sr2mux_sel = 1;
				end
        end
			
		  op_not:
		  begin
				ctrl.aluop = alu_not;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
		  end
		  
		  op_ldr:
		  begin
				ctrl.addr1mux_sel = 1;
				ctrl.addr2mux_sel = 2'b01;
				ctrl.wbmux_sel = 2'b01;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.lshf = 1;
				ctrl.dcacheR = 1;
				ctrl.dcache_enable = 1'b1;
		  end
		  
		  op_str:
		  begin
		  		ctrl.addr1mux_sel = 1;
				ctrl.addr2mux_sel = 2'b01;
				ctrl.lshf = 1;
				ctrl.storemux_sel = 1;
				ctrl.dcacheW = 1;
				ctrl.aluop = alu_passb;
				ctrl.dcache_enable = 1'b1;
		  end
		  
		  op_br:
		  begin
				ctrl.addr2mux_sel = 2'b10;
				ctrl.lshf = 1;
				ctrl.br_op = 1;
		  end
        /*all the other opcodes*/
        
        default: 
        begin
            ctrl = 0;    //Unknown opcode, set control word to zero.
        end
    endcase
end

endmodule : control_rom
