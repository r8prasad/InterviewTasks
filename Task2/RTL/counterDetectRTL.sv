module counterDetectRTL(
	input   logic clk,
			logic reset,
			logic [3:0] data,
	output  logic incr,
			logic decr,
			logic error
	);

	logic [3:0] previous_data;
	logic first_input;

	always @(posedge clk, posedge reset) begin
		if(reset) begin
			//set all flags to 0
			incr <= 0;
			decr <= 0;
			error <= 0;
			first_input <= 1;
		end
		else begin
			if(^data !== 1'bx) begin
				first_input <= 0;
				previous_data <= data;
				
				if(first_input)
					//all 3 outputs should be 0 on first data input
					{incr, decr, error} <= 3'b000;
				else begin
					if(data == previous_data + 1)
						//incr should be 1 on data increment
						{incr, decr, error} <= 3'b100;
					else if(data == previous_data - 1)
						//decr should be 1 on data decrement
						{incr, decr, error} <= 3'b010;
					else if (data == previous_data)
						//all 3 outputs should be 0 on stable data input
						{incr, decr, error} <= 3'b000;
					else
						//error should be 1 on data error
						{incr, decr, error} <= 3'b001;
				end
			end
			else begin
				//if data is unknown, outputs are also unknown
			end
		end	
	end
endmodule
