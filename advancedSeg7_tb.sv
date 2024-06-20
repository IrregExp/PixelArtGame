/* testbench for the advancedSeg7 

	Verifies that the correct value is output to the seven segment display
	based on the input "position".
*/
module advancedSeg7_tb();
	logic	clk;
	logic [5:0] position;
	logic [6:0] hex1, hex2;

	advancedSeg7 dut(position, hex1, hex2);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 1;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
		
	initial begin
		// Test 2 digit values
		position <= 6'b011111; repeat(2) @(posedge clk);
		position <= 6'b010101; repeat(2) @(posedge clk);
		position <= 6'b001111; repeat(2) @(posedge clk);
		
		// Test 1 digit values
		position <= 6'b001010; repeat(2) @(posedge clk);
		position <= 6'b000001; repeat(2) @(posedge clk);
		position <= 6'b000000; repeat(2) @(posedge clk);

		$stop;
	end
endmodule  // advancedSeg7_tb
