/*pseudo lru module for l2cache*/

module pseudolru
(
	input logic clk,
	input logic pseudolru_write,
	input logic valid0out,
	input logic valid1out,
	input logic valid2out,
	input logic valid3out,
	output logic [1:0] lru
);

logic [2:0] state;

/*	state0 = 00X - line0 is lru
	state1 = 01X - line1 is lru
	state2 = 1X0 - line2 is lru
	state3 = 1X1 - line3 is lru
	X = don't care
*/

initial
begin
   state = 3'b000; //init to line0 is lru
	lru = 2'b00;
end

always_ff @(posedge clk)
begin
    if(pseudolru_write == 1)
    begin
			if((state[2] == 0) && (state[1] == 0)) 		//Reference to line0
			begin
				lru = 2'b00;
				state = {2'b11, state[0]};
			end
			else if((state[2] == 0) && (state[1] == 1)) 	//Reference to line1
			begin
				lru = 2'b01;
				state = {2'b10, state[0]};
			end
			else if((state[2] == 1) && (state[0]) == 0)	//Reference to line2
			begin
				lru = 2'b10;
				state = {1'b0, state[1], 1'b1};
			end
			else if((state[2] == 1) && (state[0] == 1))	//Reference to line3
			begin
				lru = 2'b11;
				state = {1'b0, state[1], 1'b0};
			end
    end
end

endmodule: pseudolru