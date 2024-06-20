/* testbench for the colorSelect 

	Verifies that the colorROM is correctly accessed based 
	on the state of the "forward" (start) and "backward" (select) signals.
*/

`timescale 1 ps / 1 ps
module colorSelect_tb();
	logic clk, reset, forward, backward;
	logic [23:0] colorHex;

	colorSelect dut(clk, reset, forward, backward, colorHex);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 1;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
		
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		
		
		backward <= 0;
		// Cycle forward.
		forward <= 1; repeat(5) @(posedge clk);
		forward <= 0;
		// Ensure that the ROM is able to cycle to the other side.
		backward <= 1; repeat(6) @(posedge clk);
		backward <= 0;
	
		// Restart back at 0
		forward <= 1; repeat(21) @(posedge clk);
		forward <= 0;
		
		// Cycle through going backwards.
		backward <= 1; repeat(15) @(posedge clk);

		$stop;
	end // initial
endmodule  // advancedSeg7_tb
