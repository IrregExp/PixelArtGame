// module takes in a 6 bit value and converts it into unsigned integer so that it can
// be used to display decimal values on the HEX desplay of the DE1 board. 
module advancedSeg7(position, hex1, hex2); 
input logic [5:0] position;
output logic [6:0] hex1, hex2;

integer unsigned position_dec, msb, lsb;
	
assign position_dec = position;
assign msb = position_dec / 10; // to get the most significant bit we divide by 10
assign lsb = position_dec - msb * 10; // to get the least significant bit we do a pseudo mod

	always_comb begin // combinational logic for msb
		case (msb)
			//       Light: 6543210
			4'd0: hex1 = 7'b1000000;
			4'd1: hex1 = 7'b1111001;
			4'd2: hex1 = 7'b0100100;
			4'd3: hex1 = 7'b0110000;
			4'd4: hex1 = 7'b0011001;
			4'd5: hex1 = 7'b0010010;
			4'd6: hex1 = 7'b0000010;
			4'd7: hex1 = 7'b1111000;
			4'd8: hex1 = 7'b0000000;
			4'd9: hex1 = 7'b0010000;
			default: hex1 = 7'b1111111;
      endcase
	end
		
	always_comb begin // combinational logic for lsb
		case (lsb)
			//       Light: 6543210
			4'd0: hex2 = 7'b1000000;
			4'd1: hex2 = 7'b1111001;
			4'd2: hex2 = 7'b0100100;
			4'd3: hex2 = 7'b0110000;
			4'd4: hex2 = 7'b0011001;
			4'd5: hex2 = 7'b0010010;
			4'd6: hex2 = 7'b0000010;
			4'd7: hex2 = 7'b1111000;
			4'd8: hex2 = 7'b0000000;
			4'd9: hex2 = 7'b0010000;
			default: hex2 = 7'b1111111;
      endcase
	end
		
endmodule  // advancedSeg7