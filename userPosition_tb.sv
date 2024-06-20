/* testbench for the userPosition module 

	Verifies that the user's position is correctly output based
	on the state of the "up", "down", "left" and "right" input signals.
*/
module userPosition_tb();
	logic CLOCK_50, reset, left, right, up, down;
	logic [5:0] userX;
	logic [4:0] userY;

	userPosition dut(CLOCK_50, reset, left, right, up, down, userX, userY);

	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 1;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
		
	initial begin
		reset <= 1; @(posedge CLOCK_50);
		reset <= 0; @(posedge CLOCK_50);
		up <= 0;
		down <= 0;
		left <= 0;
		
		// Test moving right
		right <= 1; repeat(4) @(posedge CLOCK_50);
		right <= 0; @(posedge CLOCK_50);

		// Test moving down
		down <= 1; repeat(4) @(posedge CLOCK_50);
		down <= 0; @(posedge CLOCK_50);

		// Test moving left and that pointer wraps around to other side.
		left <= 1; repeat(5) @(posedge CLOCK_50);
		left <= 0; @(posedge CLOCK_50);

		// Test moving up and that pointer wraps around to other side.
		up <= 1; repeat(6) @(posedge CLOCK_50);
		up <= 0; @(posedge CLOCK_50);

		left <= 1; @(posedge CLOCK_50);
		left <= 0; @(posedge CLOCK_50);

		up <= 1; @(posedge CLOCK_50);
		up <= 0; @(posedge CLOCK_50);

		$stop;
	end // initial
endmodule  // userPosition_tb
