class counterDetect_monitor extends uvm_monitor;
	`uvm_component_utils(counterDetect_monitor)
	
	//interface
	virtual counterDetect_intf vif;
	
	//analysis port
	uvm_analysis_port #(counterDetect_seq_item) item_collected_port;
	
	//semaphores
	semaphore dataSem;
	semaphore outputSem;
	semaphore waitSem;
	
	int prev_count = 0;
	
	bit use_objections = 1'b0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db #(virtual counterDetect_intf)::get(null, "*", "vif", vif))
			`uvm_fatal(get_type_name(), $psprintf("Failed to get the interface"))
		
		//create the analysis port
		item_collected_port = new("item_collected_port", this);
		
		//create the semaphores
		dataSem = new(1);
		outputSem = new(1);
		waitSem = new(1);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		counterDetect_seq_item item_collected_A = new("item_collected_A");
		counterDetect_seq_item item_collected_B = new("item_collected_B");
		counterDetect_seq_item item_collected_C = new("item_collected_C");
		
		fork
		
			begin : reset_thread
				forever begin
					reset(phase);
				end
			end
			begin : monitor_thread1 
				forever begin
					collect_item(item_collected_A);
				end
			end
			begin : monitor_thread2
				forever begin
					collect_item(item_collected_B);
				end
			end
			begin : monitor_thread3
				forever begin
					collect_item(item_collected_C);
				end
			end
		join
	endtask : run_phase
	
	task reset(uvm_phase phase);
		uvm_objection objection;
		uvm_object object_list[$];
		
		vif.wait_posedge_rst();
		`uvm_info(get_type_name(), $psprintf("Reset found"), UVM_MEDIUM)
		
		//if reset is set again in the middle of the transactions, drop all objections
		if(use_objections) begin
			// Fetching the objection from current phase
			objection = phase.get_objection();
 
			// Collecting all the objects which doesn't drop the objection 
			objection.get_objectors(object_list);
 
			// Dropping the objection forcefully
			foreach(object_list[i]) begin
				while(objection.get_objection_count(object_list[i]) != 0) begin
					objection.drop_objection(object_list[i]);
				end
			end
		end
		vif.wait_negedge_rst();

	endtask : reset
	
	task collect_item(counterDetect_seq_item item_collected);
		vif.wait_negedge_rst();
		
		//if reset is set in the middle of the transactions, drop all objections
		use_objections = 1'b1;
		
		//get seq item from interface
		dataSem.get(1);
		@(posedge vif.MONITOR.clk);
		wait(vif.MONITOR.count != prev_count);
		item_collected.data = vif.MONITOR.data;
		item_collected.count = vif.MONITOR.count;
		prev_count = vif.MONITOR.count;
		`uvm_info(get_type_name(), $psprintf("Data found: %b", vif.MONITOR.data), UVM_MEDIUM)
		dataSem.put(1);
		
		//wait state for signals 
		waitSem.get(1);
		@(posedge vif.MONITOR.clk);
		waitSem.put(1);
		
		//get output signals
		outputSem.get(1);
		@(posedge vif.MONITOR.clk);
		item_collected.incr = vif.MONITOR.incr;
		item_collected.decr = vif.MONITOR.decr;
		item_collected.error = vif.MONITOR.error;
		`uvm_info(get_type_name(), $psprintf("Output found: incr - %b, decr - %b, error - %b", vif.MONITOR.incr, vif.MONITOR.decr, vif.MONITOR.error), UVM_MEDIUM)
		
		item_collected_port.write(item_collected);
		outputSem.put(1);
		
	endtask : collect_item

endclass : counterDetect_monitor