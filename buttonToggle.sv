// module toggles button inputs so that button must be released before input is instantiated.
// used when on board clock cycle is significantly faster than user input 
module buttonToggle (clk, reset, buttonIn, buttonOut);
input logic clk, reset, buttonIn;
output logic buttonOut;

	enum {s0, s1, s2} ps, ns; // present state and next state declarations
	
	always_comb begin
		case (ps)
			s0: if (buttonIn) ns = s1; // button is pressed
				  else ns = s0;
		   s1: if (~buttonIn) ns = s2; // button is no longer pressed
				  else ns = s1;
		   s2: ns = s0; // button signal is declard for one clock cycle
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= s0;
		end else begin
			ps <= ns;
		end
	end
	
	assign buttonOut = (ps == s2);

endmodule // buttonToggle