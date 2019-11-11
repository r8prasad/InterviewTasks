class counterDetect_random_sequence extends uvm_sequence #(counterDetect_seq_item);
	`uvm_object_utils(counterDetect_random_sequence)
	
	`uvm_declare_p_sequencer(counterDetect_sequencer)
	
	int trans_count;
	
	//constructor
	function new(string name = "counterDetect_random_sequence");
		super.new(name);
	endfunction : new

	
	task body();
		counterDetect_seq_item req;
		int op;
		bit [3:0] prevData, currData;
		bit firstData;
		
		for(int i=0; i<trans_count; i++) begin
		
			firstData = (i==0);
			currData = randomize_data(firstData, prevData);
			
			`uvm_do_with(req,{
							req.data==currData;
							req.count==i+1;
							})
			prevData = currData;
		end
	endtask : body
	
	
	local function bit [3:0] randomize_data(bit firstData, bit [3:0] prevData);
		int op = $urandom_range(1, 4);
		
		if(firstData || op == 4)//first data or random data
			return $urandom;
		else if(op == 1) //increment
			return prevData + 1;
		else if(op == 2) //decrement
			return prevData - 1;
		else // op == 3 stable
			return prevData;
	endfunction : randomize_data

endclass : counterDetect_random_sequence