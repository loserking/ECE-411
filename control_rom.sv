/*the control rom module that holds all the control signals for the pipelined processor*/

import lc3b_types::*;

module control_rom
(
    input lc3b_opcode opcode,
    input logic ir11,
	 input logic [2:0] lc3x_control,
	 input logic ir4,
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
	 ctrl.alu_result_mux_sel = 2'b00;
	 ctrl.d_mem_byte_sel = 1'b0;
	 ctrl.stb_op = 1'b0;
	 ctrl.ldi_op = 1'b0;
	 ctrl.sti_op = 1'b0;
	 ctrl.ldb_op = 1'b0;
	 ctrl.sr1_needed = 1'b0;
	 ctrl.sr2_needed = 1'b0;
	 ctrl.dr_needed = 1'b0;
	 
	 
	 ctrl.div_op = 1'b0;
	 ctrl.mult_op = 1'b0;
	 ctrl.sub_op = 1'b0;
	 ctrl.xor_op = 1'b0;
	 ctrl.or_op = 1'b0;
	 ctrl.nor_op = 1'b0;
	 ctrl.xnor_op = 1'b0;
	 ctrl.nand_op = 1'b0;
	 ctrl.ldbse_op = 1'b0;
	 


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
				if(ir4) //nand
				begin
					ctrl.aluop = alu_nand;
					ctrl.nand_op = 1;
				end
				else
				begin
					ctrl.aluop = alu_and;
				end
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
				ctrl.alu_result_mux_sel = 2'b01;
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
		 
		 
		 op_rti:
		 begin
			if(lc3x_control == 3'b000)  //div
			begin
				ctrl.div_op = 1;
				ctrl.alu_result_mux_sel = 2'b11;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b001) //mult
			begin
				ctrl.mult_op = 1;
				ctrl.alu_result_mux_sel = 2'b10;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b010) //sub
			begin
				ctrl.sub_op = 1;
				ctrl.aluop = alu_sub;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b011) //xor
			begin
				ctrl.xor_op = 1;
				ctrl.aluop = alu_xor;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
				
			end
			if(lc3x_control == 3'b100) //or
			begin
				ctrl.or_op = 1;
				ctrl.aluop = alu_or;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b101) //nor
			begin
				ctrl.nor_op = 1;
				ctrl.aluop = alu_nor;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b110) //xnor
			begin
				ctrl.xnor_op = 1;
				ctrl.aluop = alu_xnor;
				ctrl.load_reg = 1;
				ctrl.load_cc = 1;
				ctrl.wbmux_sel = 2'b11;
				ctrl.sr1_needed = 1;
				ctrl.sr2_needed = 1;
				ctrl.dr_needed = 1;
			end
			if(lc3x_control == 3'b111) //ldbse
			begin
				ctrl.ldbse_op = 1;
				//for now I'm just putting what ldb isand I'll figure it out at the end
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
			
		 end
        /*all the other opcodes*/
        
        default: 
        begin
            ctrl = 0;    //Unknown opcode, set control word to zero.
        end
    endcase
end

endmodule : control_rom
