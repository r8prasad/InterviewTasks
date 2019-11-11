class counterDetect_seq_item extends uvm_sequence_item;
	`uvm_object_utils(counterDetect_seq_item)
	
	rand	bit[3:0] data;  //input data to counter
			bit incr;		//output increment flag
			bit decr;		//output decrement flag
			bit error;		//output error flag
	rand	int count;		//seq item tag to track b/w consecutive items
	
	//constructor
	function new(string name = "counterDetect_seq_item");
		super.new(name);
	endfunction : new
endclass