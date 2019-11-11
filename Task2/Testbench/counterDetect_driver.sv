class counterDetect_driver extends uvm_driver #(counterDetect_seq_item);
	`uvm_component_utils(counterDetect_driver)
		
	//virtual interface
	virtual counterDetect_intf vif;
		
	//semaphores
	semaphore dataSem;
	semaphore outputSem;
	semaphore waitSem;

	bit use_objections = 1'b0;
	
	//constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction :  new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db #(virtual counterDetect_intf)::get(null, "*", "vif", vif))
			`uvm_fatal(get_type_name(), $psprintf("Failed to get the interface"))
			
		dataSem = new(1);
		outputSem = new(1);
		waitSem = new(1);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		counterDetect_seq_item req_item_A;
		counterDetect_seq_item req_item_B;
		counterDetect_seq_item req_item_C;
		
		fork
			begin : reset_thread
				forever begin
					reset(phase);
				end
			end
			begin : get_and_drive_thread_A
				forever begin
					get_and_drive(req_item_A);
				end
			end
			begin : get_and_drive_thread_B
				forever begin
					get_and_drive(req_item_B);
				end
			end
			begin : get_and_drive_thread_C
				forever begin
					get_and_drive(req_item_C);
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

	task get_and_drive(counterDetect_seq_item req_item);
		
		//wait for negedge reset
		vif.wait_negedge_rst();
		
		//if reset is set in the middle of the transactions, drop all objections
		use_objections = 1'b1;
		
		//send seq item to interface
		dataSem.get(1);
		seq_item_port.get(req_item);
		
		@(posedge vif.DRIVER.clk);
		vif.DRIVER.data <= req_item.data;
		vif.DRIVER.count <= req_item.count;
		`uvm_info(get_type_name(), $psprintf("Data sent: %b", req_item.data), UVM_MEDIUM)
		dataSem.put(1);
		
		//signals get latched to interface
		waitSem.get(1);
		@(posedge vif.DRIVER.clk);
		waitSem.put(1);
		
		//get output signals
		outputSem.get(1);
		@(posedge vif.DRIVER.clk);
		req_item.incr <= vif.DRIVER.incr;
		req_item.decr <= vif.DRIVER.decr;
		req_item.error <= vif.DRIVER.error;
		`uvm_info(get_type_name(), $psprintf("Output received: incr - %b, decr - %b, error - %b", vif.DRIVER.incr, vif.DRIVER.decr, vif.DRIVER.error), UVM_MEDIUM)

		outputSem.put(1);
		
	endtask : get_and_drive
endclass : counterDetect_driver