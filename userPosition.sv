// user position tracks current user position using left, right, up, and down
// goes up to 31 and cycles back to 0 was 31 is passed.
module userPosition (CLOCK_50, reset, left, right, up, down, userX, userY);
	input logic CLOCK_50, reset, left, right, up, down;
	output logic [5:0] userX; // 5 bits, so a "32nd" pixel can be accessed (access UI on side bar)
	output logic [4:0] userY; // 0 to 31


	always_ff @(posedge CLOCK_50) begin
		if (reset) begin // position set to 0 on reset
			userX <= 0;
			userY <= 0;
		end else begin
			if (up) begin
			    if (userY == 0) begin // up overflow case
			        userX <= userX;
			        userY <= 31;
			    end else begin
				    userX <= userX;
				    userY <= userY - 1; // y decrement for up
				end
			end else if (down) begin
				if (userY == 31) begin // down overflow case
				    userX <= userX;
				    userY <= 0;
				end else begin
				    userX <= userX;
				    userY <= userY + 1; // y increment for down
				end
			end else if (right) begin
				if (userX == 32) begin // right overflow case
					userX <= 0;
					userY <= userY;
				end else begin
					userX <= userX + 1; // x increment for right
					userY <= userY;
				end
			end else if (left) begin
			    if (userX == 0) begin // left overflow case
			        userX <= 32;
			        userY <= userY;
			    end else begin
			    	userX <= userX - 1; // x decrement for left
				    userY <= userY;
				end
			end else begin
				userX <= userX; // otherwise x and y positions remain the same.
				userY <= userY;
			end
		end
	end

endmodule // userPosition