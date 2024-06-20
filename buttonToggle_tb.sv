/*
Verifies that the input signal is only asserted for one clock cycle

The output of the buttonToggle module is used as input for the reset of the game.
Given the clock rate is so fast, a single button press would cause the pixel to move
much more than desired.

*/
module buttonToggle_tb();
    logic clk, reset, buttonIn;
    logic buttonOut;
    
    buttonToggle dut(clk, reset, buttonIn, buttonOut);
    
    parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 1;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
    	
    initial begin
        reset <= 1; repeat(2) @(posedge clk);
        reset <= 0; repeat(2) @(posedge clk);
        // Test button presses for multiple clock cycles.
        buttonIn <= 1; repeat(5) @(posedge clk);
        buttonIn <= 0; repeat(5) @(posedge clk);
        
        // Test with a single clock cycle.
        buttonIn <= 1; repeat(1) @(posedge clk);
        buttonIn <= 0; repeat(1) @(posedge clk);
        
        buttonIn <= 1; repeat(1) @(posedge clk);
        buttonIn <= 0; repeat(10) @(posedge clk);
        
        // Test for many clock cycles.
        buttonIn <= 1; repeat(50) @(posedge clk);
        buttonIn <= 0; repeat(4) @(posedge clk);
    
        $stop;
    end
endmodule  // end buttonToggle_tb