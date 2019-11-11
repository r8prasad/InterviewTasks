`include "counterDetect_agent.sv"
`include "counterDetect_scb.sv"

class counterDetect_env extends uvm_env;
	`uvm_component_utils(counterDetect_env)
	
	counterDetect_scb scb;
	counterDetect_agent agent;
	
	//constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		//create scoreboard and agent
		agent = counterDetect_agent::type_id::create("agent", this);
		scb = counterDetect_scb::type_id::create("scb", this);
	endfunction : build_phase
	
	//connect phase
	function void connect_phase(uvm_phase phase);
		//connect scoreboard export with monitor port
		agent.mon.item_collected_port.connect(scb.item_collected_export);
	endfunction : connect_phase

endclass : counterDetect_env