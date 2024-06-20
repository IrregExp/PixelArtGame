/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *   V_GPIO       - GPIO pins used to control the N8 controller.
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
	
module DE1_SoC(
    input CLOCK_50,
    inout [35:0] V_GPIO,
    output [6:0] HEX0, 
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [9:0] LEDR,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_BLANK_N,
    output VGA_CLK,
    output VGA_HS,
    output VGA_SYNC_N,
    output VGA_VS);
	 
	assign HEX2 = '1;
	assign HEX3 = '1;


    // Buttons on N8. Input into N8_driver.
	wire up;
	wire down;
	wire left;
	wire right;
	wire a;
	wire b;
	wire start;
	wire select;
	
	// Output of passing respective N8 button through buttonToggle module.
	// These signals are used to drive the game.
	logic up_out;
	logic down_out;
	logic left_out;
	logic right_out;
	logic a_out;
	logic b_out;
	logic start_out;
	logic select_out;
	
	// Used for N8 driver.
    wire latch;
    wire pulse;
	
	logic reset;
	
	logic [23:0] colorSelected;  // Color selected in the ROM
	logic [23:0] currPixelColor; // Current color of the pixel
    
    // User's position on screen. In units of "pixels" where each "pixel" = 15 x 15 actual pixels
	// userX ranges from 0 to 32 (extra square for "reset" screen on the right)
	logic [5:0] userX = 0;
	logic [4:0] userY = 0;
	 
	// Used for N8 driver
    assign V_GPIO[27] = pulse;
    assign V_GPIO[26] = latch;
    
	// Input to video_driver
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] red, green, blue;
	
	logic [23:0] pixelWriteColor; // pixel color written to RAM.
	logic [23:0] pixelColor;     // temporary signal, based on whether a_out is asserted

	logic [15:0] sideImageColorUnselect_565; // 565 encoded color of side UI. Image when reset is not selected.
	logic [15:0] sideImageColorSelect_565;   // 565 encoded color of side UI. Image when reset is selected.
	
	logic [23:0] sideImageColorUnselect_888; // 888 encoded color of side UI. Image when reset is not selected.
	logic [23:0] sideImageColorSelect_888;   // 888 encoded color of side UI. Image when reset is selected.
	
	// Addresses for Pixels in RAM
	logic [9:0] rdaddress;
	logic [9:0] wraddress;
	
	// Address for pixels in side image
	logic [16:0] imageAddr;
	
	// Determines the r, g and b values to set as input to video_driver.
	// Based on current x and y coordinates.
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			// Set pixels in drawing area to black
		    if  (x < 480 && y < 480) begin
		        red <= 24'b0;
		        green <= 24'b0;
		        blue <= 24'b0;
			// Set pixels in UI area to the unselected image color (888 encoded).
		   end  else begin 
		        red <= sideImageColorUnselect_888[23:16];
			    green <= sideImageColorUnselect_888[15:8];
			    blue <= sideImageColorUnselect_888[7:0];
		    end
		// If the current pixel of the vga driver
		// is in range of current pixel selected by user
		// set the color to selected color (don't overwrite RAM though).
		end else if (userX <= 31 && x / 15 == userX && y / 15 == userY) begin
			red <= colorSelected[23:16];
			green <= colorSelected[15:8];
			blue <= colorSelected[7:0];
		// Set pixels in remaining squares to the pixel colors in RAM
		// currPixelColor is calculated based on values of x and y
		end else if (x < 480 && y < 480) begin
			red <= currPixelColor[23:16];
			green <= currPixelColor[15:8];
			blue <= currPixelColor[7:0];
		end else begin
		    // Based on userX position. If userX is at 32, set the UI to reset selected image.
		    if (userX > 31) begin  
		        red <= sideImageColorSelect_888[23:16];
		        green <= sideImageColorSelect_888[15:8];
		        blue <= sideImageColorSelect_888[7:0];
		    end else begin
			    red <= sideImageColorUnselect_888[23:16];
			    green <= sideImageColorUnselect_888[15:8];
			    blue <= sideImageColorUnselect_888[7:0];
			 end
		end
	end // always_ff
	
	
	always_ff @(posedge CLOCK_50) begin
	    if (userX > 31 && a_out) begin 
	        reset <= 1;
	        LEDR[9] <= 1;
	   end else if (reset && (a_out | b_out)) begin
	        reset <= 0;
	        LEDR[9] <= 0;
	   end
	end
		
	// Temporary signal. If b_out is asserted, clear the current pixel
	// otherwise set it to the color selected in ROM.	
	assign pixelColor = a_out ? colorSelected : 24'b0;
	
	// If reset is asserted, clear the pixel. Otherwise, update the pixel to pixelColor.
	assign pixelWriteColor = reset ? 24'b0 : pixelColor;
	
	// Current x and y position, mapped to respective memory addr in RAM
	assign rdaddress = 32*(y/15) + x/15;
	
	// User's x and y position, mapped to respective memory in RAM.
	assign wraddress = reset ? rdaddress : 32*userY + userX;
	
	// Current x and y position to access corresponding value in ROM
	assign imageAddr = x >= 480 ? ((x - 480) + 160*y) : 0;
	
	// Convert 565 color encoding to 888
	assign sideImageColorUnselect_888 = {
					sideImageColorUnselect_565[15:11], 3'b000,
					sideImageColorUnselect_565[10:5], 2'b00,
					sideImageColorUnselect_565[4:0], 3'b000};
	
	assign sideImageColorSelect_888 = {
					sideImageColorSelect_565[15:11], 3'b000,
					sideImageColorSelect_565[10:5], 2'b00,
					sideImageColorSelect_565[4:0], 3'b000};
					
	
	// VGA driver
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset(0), .x, .y, .r(red), .g(green), .b(blue),
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	// N8 controller driver
	n8_driver driver(
        .clk(CLOCK_50),
        .data_in(V_GPIO[28]),
        .latch(latch),
        .pulse(pulse),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .select(select),
        .start(start),
        .a(a),
        .b(b)
    );
	 
	 // Initialize buttonToggle for each of the 8 buttons
	 // up button press
	 buttonToggle upPress (
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(up),
			.buttonOut(up_out)
	);
	
	// down button press
	buttonToggle downPress (
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(down),
			.buttonOut(down_out)
	);
	
	// left button press
	buttonToggle leftPress (
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(left),
			.buttonOut(left_out)
	);
	
	// right button press
	buttonToggle rightPress (
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(right),
			.buttonOut(right_out)
	);
	
	// a button (set pixel) press
	buttonToggle aPress(
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(a),
			.buttonOut(a_out)
	);
	
	// b button (clear pixel) press
	buttonToggle bPress(
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(b),
			.buttonOut(b_out)
	);
	
	// start button (cycle color wheel forward) press
	buttonToggle startPress(
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(start),
			.buttonOut(start_out)
	);
	
	// select button (cycle color wheel backward) press
	buttonToggle selectPress(
			.clk(CLOCK_50),
			.reset(0),
			.buttonIn(select),
			.buttonOut(select_out)
	);
	
	// Updates userX and userY position based on states of up/down/left/right
	userPosition pos (.CLOCK_50, 
							.reset, 
							.left(left_out), 
							.right(right_out),
							.up(up_out),
							.down(down_out),
							.userX,
							.userY
	);
	
	// Outputs the userX and userY position to hex display.
	advancedSeg7 displayx (.position({1'b0, userX}), .hex1(HEX5), .hex2(HEX4));
    advancedSeg7 displayy (.position({1'b0, userY}), .hex1(HEX1), .hex2(HEX0));
	

	// Select color in color wheel (ROM) based on state of start and select
	colorSelect color (
			.clk(CLOCK_50),
			.reset,
			.forward(start_out),
			.backward(select_out),
			.colorHex(colorSelected)
	);
	
	// Used to store current colors of each pixel (RAM).
	pixelsRAM pixels (
			.clock(CLOCK_50),
			.data(pixelWriteColor),
			.rdaddress,
			.wraddress,
			.wren(a_out | b_out | reset),
			.q(currPixelColor)
	);
	
	sideImgROM_unselect rstUnselect (
			.address(imageAddr),
			.clock(CLOCK_50),
			.q(sideImageColorUnselect_565)
	);
	 
	sideImgROM_select rstSelect (
			.address(imageAddr),
			.clock(CLOCK_50),
			.q(sideImageColorSelect_565)
	); 
endmodule // DE1_SoC