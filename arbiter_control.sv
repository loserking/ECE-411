/*Control logic for the arbiter*/
/*the arbiter controller*/


module arbiter_control
(
    /* Input and output port declarations */
    input clk,
    input logic i_mem_read,
	 input logic i_mem_write,
	 input logic d_mem_read,
	 input logic d_mem_write,
	 input logic l2_mem_resp,
	 input logic l2hit,
	 
	 //To arbiter datapath
	 output logic readsignalmux_sel,
	 output logic writesignalmux_sel,
	 output logic memaddressmux_sel,
	 output logic memwdatamux_sel,
	 output logic memrdatademux_sel,
	 output logic byteenablemux_sel,
	 output logic memrespmux_sel
);

enum int unsigned {
    /* List of states */
    s_idle,
	 s_imiss,
	 s_dmiss,
	 s_bothmiss
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignmen	 input logic arbiter_ts */
    
    /* Actions for each state */
     
	  readsignalmux_sel = 1'b0;
	  writesignalmux_sel = 1'b0;
	  memaddressmux_sel = 1'b0;
	  memwdatamux_sel = 1'b0;
	  memrdatademux_sel = 1'b0;
	  memrespmux_sel = 1'b0;
	  byteenablemux_sel = 1'b0;
     case(state)
			s_idle:begin
			end
			s_imiss:begin
				readsignalmux_sel = 1'b1;
				writesignalmux_sel = 1'b1;
				memaddressmux_sel = 1'b1;
				memwdatamux_sel = 1'b1;
				memrdatademux_sel = 1'b1;
				memrespmux_sel = 1'b1;
				byteenablemux_sel = 1'b1;
			end
			s_dmiss:begin
			end
			s_bothmiss:begin
			end
     default:/* Do nothing */;
     endcase 
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
     next_state = state;

     case(state)
        s_idle:begin
				if((i_mem_read || i_mem_write) &&(d_mem_read || d_mem_write))
					next_state = s_bothmiss;
				else if(i_mem_read || i_mem_write)
					next_state = s_imiss;
				else if((d_mem_read || d_mem_write) &(!l2hit))
					next_state = s_dmiss;
				else 
					next_state = s_idle;
			end
			s_imiss:begin
				if((l2_mem_resp == 1 ) && (!(d_mem_read || d_mem_write)))
					next_state = s_idle;
				else if((l2_mem_resp == 1 ) && (d_mem_read || d_mem_write))
					next_state = s_dmiss;
				else 
					next_state = s_imiss;
			end
			s_dmiss:begin
				if(l2_mem_resp == 1)
					next_state = s_idle;
				else
					next_state = s_dmiss;
			end
			s_bothmiss:begin
				if(l2_mem_resp == 1)
					next_state = s_imiss;
				else
					next_state = s_bothmiss;
			end
		   default: 
				next_state = s_idle;
        endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
     begin : next_state_assignment
         state <= next_state;
     end
end

endmodule : arbiter_control
