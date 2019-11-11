class counterDetect_scb extends uvm_scoreboard;
	`uvm_component_utils(counterDetect_scb)
	
	uvm_analysis_imp #(counterDetect_seq_item, counterDetect_scb) item_collected_export;
	
	bit [3:0] previousData;
	
	int trans_cnt, error_cnt = 0;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	//build phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_collected_export = new("item_collected_export", this);
	endfunction : build_phase
	
	function void write(counterDetect_seq_item trans);
		
		if(!check_data(trans)) begin
			error_cnt++;
			`uvm_error(get_type_name(), $psprintf("Incorrect output. CurrData=%b, PrevData=%b, Incr=%b, Decr=%b, Error=%b", trans.data, previousData, trans.incr, trans.decr, trans.error))
		end	

		previousData = trans.data;
		trans_cnt++;
	endfunction : write
	
	local function bit check_data(counterDetect_seq_item trans);
		if(trans.count == 1)//first data
			return (!trans.incr && !trans.decr && !trans.error);
		else if(trans.data == previousData+1)//increment 
			return (trans.incr && !trans.decr && !trans.error);
		else if(trans.data == previousData-1)//decrement
			return (!trans.incr && trans.decr && !trans.error);
		else if(trans.data == previousData)//stable
			return (!trans.incr && !trans.decr && !trans.error);
		else//error
			return (!trans.incr && !trans.decr && trans.error);
	endfunction : check_data
	
	//finally report status
	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $psprintf("Total number of transactions: %0d", trans_cnt), UVM_MEDIUM)
		if(error_cnt > 0)
			`uvm_error(get_type_name(), $psprintf("%0d transactions failed", error_cnt))
	endfunction : report_phase

endclass : counterDetect_scb