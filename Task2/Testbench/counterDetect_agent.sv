`include "counterDetect_sequencer.sv"
`include "counterDetect_monitor.sv"
`include "counterDetect_driver.sv"

class counterDetect_agent extends uvm_agent;
	`uvm_component_utils(counterDetect_agent)

	counterDetect_monitor mon;
	counterDetect_sequencer seqncr;
	counterDetect_driver drive;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		//create monitor, sequencer, driver
		mon = counterDetect_monitor::type_id::create("mon", this);
		seqncr = counterDetect_sequencer::type_id::create("seqncr", this);
		drive = counterDetect_driver::type_id::create("drive", this);
	endfunction : build_phase
	
	//connect phase
	function void connect_phase(uvm_phase phase);
		//connect driver and sequencer
		drive.seq_item_port.connect(seqncr.seq_item_export);
	endfunction : connect_phase

endclass : counterDetect_agent