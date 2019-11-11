`include "counterDetect_intf.sv"
`include "counterDetect_base_test.sv"
`include "counterDetect_random_test.sv"

module counterDetect_tb;

	//clk and reset
	bit clk, reset;
	
	//clock
	always #5 clk = ~clk;

	//reset
	initial begin
		reset = 1;
		#5 reset = 0;
	end
	
	//interface
	counterDetect_intf intf(clk, reset);

	//DUT
	counterDetectRTL DUT(
		.clk(intf.clk),
		.reset(intf.reset),
		.data(intf.data),
		.incr(intf.incr),
		.decr(intf.decr),
		.error(intf.error)
	);
	
	//store interface in config db
	initial begin
		uvm_config_db #(virtual counterDetect_intf)::set(null, "*", "vif", intf);
	end
	
	//dump file
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
	end
	
	//run test
	initial begin
		run_test();
	end

endmodule