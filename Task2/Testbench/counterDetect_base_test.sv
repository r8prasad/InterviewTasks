`include "counterDetect_seq_item.sv"
`include "counterDetect_env.sv"
`include "counterDetect_sequence.sv"

class counterDetect_base_test extends uvm_test;

	`uvm_component_utils(counterDetect_base_test)

	//env
	counterDetect_env env;
	
	//constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//create env
		env = counterDetect_env::type_id::create("env", this);
	endfunction : build_phase
	
endclass : counterDetect_base_test