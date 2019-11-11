class counterDetect_sequencer extends uvm_sequencer #(counterDetect_seq_item);
	`uvm_component_utils(counterDetect_sequencer)
	
	//constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : counterDetect_sequencer