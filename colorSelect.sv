// color select takes a forward and backward input that is used to traverse through a ROM module holding 16 24 bit color values 
module colorSelect(clk, reset, forward, backward, colorHex);
input logic clk, reset, forward, backward;
output logic [23:0] colorHex; // a hex is 4 bits so 4 x 6 = 24

logic [23:0] ROMOut;
logic[3:0] pointerPosition;

//instantiate the ROM
colorROM color (.address(pointerPosition), .clock(clk), .q(ROMOut));

assign colorHex = ROMOut;

always_ff @(posedge clk) begin
	if (reset) begin // upon reset we set the pointer back to 0
		pointerPosition <= 0;
	end else if (forward) begin
		if (pointerPosition < 15) begin
			pointerPosition <= pointerPosition + 1; // if forward is pressed the pointer will go forwards in the ROM
		end else begin
			pointerPosition <= 0; // if we have reached the end of the ROM the pointer will go back to 0
		end
	end else if (backward) begin
		if (pointerPosition > 0) begin
			pointerPosition <= pointerPosition - 1; // if backward is pressed the pointer will go backwards in the ROM
		end else begin
			pointerPosition <= 15; // if we have reached the beginning of the ROM the pointer will go to 15
		end
	end
end 
endmodule // colorSelect