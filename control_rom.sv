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
	 ctrl.addr3mux_sel = 1'b0;
	 ctrl.br_op = 1'b0;
	 ctrl.jsr_op = 1'b0;
	 ctrl.trap_op = 1'b0;
	 ctrl.uncond_op = 1'b0;
	 ctrl.jmp_op = 1'b0;
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
	 ctrl.dest_mux_sel = 1'b0;
	 ctrl.alu_result_mux_sel = 1'b0;
	 ctrl.d_mem_byte_sel = 1'b0;
	 ctrl.stb_op = 1'b0;
	 ctrl.ldi_op = 1'b0;
	 ctrl.sti_op = 1'b0;
	 ctrl.ldb_op = 1'b0;
	 ctrl.sr1_needed = 1'b0;
	 ctrl.sr2_needed = 1'b0;
	 ctrl.dr_needed = 1'b0;


    /*Assign control signals based on opcode */
    case(opcode)
        op_add: 
        begin 
            ctrl.aluop = alu_add;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
				if(ir5)
				begin
					ctrl.sr2mux_sel = 1;
					ctrl.sr2_needed = 0;
				end
        end

        op_and: 
        begin
            ctrl.aluop = alu_and;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
				if(ir5)
				begin
					ctrl.sr2mux_sel = 1;
					ctrl.sr2_needed = 0;
				end
        end
			
		  op_not:
		  begin
				ctrl.aluop = alu_not;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
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
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
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
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		  
		  op_br:
		  begin
				ctrl.addr2mux_sel = 2'b10;
				ctrl.lshf = 1;
				ctrl.br_op = 1;
		  end
		  op_lea:
		  begin
				ctrl.addr2mux_sel = 2'b10;
				ctrl.lshf = 1;
				ctrl.storemux_sel = 1;
				ctrl.load_cc = 1;
				ctrl.load_reg = 1;
				ctrl.dr_needed = 1;
		  end
		  op_jmp:										/*same as RET*/
		  begin
				//all we need to do is pass sr1_out from the regfile into the pc
				ctrl.jmp_op = 1;
				ctrl.sr1_needed = 1;
				ctrl.uncond_op = 1;
		  end
		  
		  op_jsr:
		  begin
				ctrl.dest_mux_sel = 1;
				ctrl.load_reg = 1;
				ctrl.jsr_op = 1;
				ctrl.uncond_op = 1;
				
				//then this goes into mem address and we send target pc to the pc
				if(ir11 == 0)
				begin
						//JSRR is just a jump
						ctrl.jmp_op = 1;
						//first, make R7 hold the incremented PC value
						ctrl.wbmux_sel = 2'b10;
						ctrl.jsr_op = 0;
						ctrl.sr1_needed = 1;
				end
				if(ir11 == 1)//jsr
				begin
					ctrl.br_op = 1;
					ctrl.addr2mux_sel = 2'b11;
					ctrl.lshf = 1;
					//first, make R7 hold the incremented PC value
					ctrl.wbmux_sel = 2'b10;
				end
		  end
		  
		  op_trap:
		  begin
				//put the incremented pc into R7
				ctrl.dest_mux_sel = 1;
				ctrl.load_reg = 1;
				ctrl.trap_op = 1;
				ctrl.wbmux_sel = 2'b10;
				//then zext+lsfht
				ctrl.addr3mux_sel = 1;
				ctrl.dcache_enable = 1;
				ctrl.dcacheR = 1;
				ctrl.uncond_op = 1;
				//pc_mux_sel gets 2'b10 and  sends mem_trap in the PC
		  end
		  
		  op_shf:
		  begin
				ctrl.alu_result_mux_sel = 1;
				ctrl.load_cc = 1;
				ctrl.load_reg = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		  
		  op_ldb:
		  begin
				ctrl.addr1mux_sel = 1;
				ctrl.addr2mux_sel = 2'b01;
				ctrl.wbmux_sel = 2'b01;
				ctrl.load_cc = 1;
				ctrl.load_reg = 1;
				ctrl.dcache_enable = 1;
				ctrl.dcacheR = 1;
				ctrl.d_mem_byte_sel = 1;
				ctrl.ldb_op = 1;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		  
		  op_stb:
		  begin
				ctrl.addr2mux_sel = 2'b01;
				ctrl.addr1mux_sel = 1;
				ctrl.storemux_sel = 1;
				ctrl.dcache_enable = 1;
				ctrl.dcacheW = 1;
				ctrl.aluop = alu_passb;
				ctrl.stb_op = 1;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		  
		  op_ldi:
		  begin
				ctrl.addr1mux_sel = 1;
				ctrl.addr2mux_sel = 2'b01;
				ctrl.wbmux_sel = 2'b01;
				ctrl.load_cc = 1;
				ctrl.lshf = 1;
				ctrl.load_reg = 1;
				ctrl.dcacheR = 1;
				ctrl.ldi_op = 1;
				ctrl.dcache_enable = 1;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		  
		  op_sti:
		  begin
				ctrl.addr2mux_sel = 2'b01;
				ctrl.addr1mux_sel = 1;
				ctrl.lshf = 1;
				ctrl.storemux_sel = 1;
				ctrl.dcacheW = 1;
				ctrl.aluop = alu_passb;
				ctrl.dcache_enable = 1;
				ctrl.sti_op = 1;
				ctrl.sr1_needed = 1;
				ctrl.dr_needed = 1;
		  end
		 
        /*all the other opcodes*/
        
        default: 
        begin
            ctrl = 0;    //Unknown opcode, set control word to zero.
        end
    endcase
end

endmodule : control_rom
