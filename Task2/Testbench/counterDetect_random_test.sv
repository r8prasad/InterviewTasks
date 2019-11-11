class counterDetect_random_test extends counterDetect_base_test;
	`uvm_component_utils(counterDetect_random_test)
	
	//sequence
	counterDetect_random_sequence rand_seq;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		//create sequence
		rand_seq = counterDetect_random_sequence::type_id::create("rand_seq");
		rand_seq.trans_count = 100;
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		//start sequence on sequencer
		rand_seq.start(env.agent.seqncr);
		phase.drop_objection(this);
		
		//set drain-time for the environment
		phase.phase_done.set_drain_time(this, 30);
	endtask : run_phase

endclass : counterDetect_random_test