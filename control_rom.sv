/*the control rom module that holds all the control signals for the pipelined processor*/

import lc3b_types::*;

module control_rom
(
    input lc3b_opcode opcode,
    input logic ir11,
    input logic ir5,
    output lc3b_control_word ctrl
);

always_comb
begin 
    /*Default value assignments --- make sure you do one for each signal or it will tell you to use blocking assignments*/
    ctrl.opcode = opcode;
    ctrl.load_cc = 1'b0;
    ctrl.load_regfile = 1'b0;
    ctrl.pc_mux_sel = 2'b00;
    ctrl.load_pc = 1'b0;
    ctrl.storemux_sel = 1'b0;
    ctrl.destmux_sel = 1'b0;
    ctrl.dcachereadmux_sel = 1'b0;
    ctrl.dcachewritemux_sel = 1'b0;

    /*Assign control signals based on opcode */
    case(opcode)
        op_add: 
        begin 
            ctrl.aluop = alu_add;
        end

        op_and: 
        begin
            ctrl.aluop = alu_and;
        end

        /*all the other opcodes*/
        
        default: 
        begin
            ctrl = 0;    //Unknown opcode, set control word to zero.
        end
    endcase
end

endmodule : control_rom
