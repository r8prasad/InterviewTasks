interface counterDetect_intf(input clk, reset);
	logic [3:0] data;
	logic incr;
	logic decr;
	logic error;
	logic [31:0] count;
	
	modport DRIVER(
		input clk,
		input reset,
		output data,
		output count,
		input incr,
		input decr,
		input error
	);

	modport MONITOR(
		input clk,
		input reset,
		input data,
		input incr,
		input decr,
		input error,
		input count
	);
	
	task wait_posedge_rst();
		if(reset != 1'b1)
			@(posedge reset);
	endtask : wait_posedge_rst
	
	task wait_negedge_rst();
		if(reset != 1'b0)
			@(negedge reset);
	endtask : wait_negedge_rst

	//sequences
	sequence seq_incr;
		//data increment sequence
		data == $past(data, 1) + 1;
	endsequence
	
	sequence seq_decr;
		//data decrement sequence
		data == $past(data, 1) - 1;
	endsequence
	
	sequence seq_stable;
		//data stable sequence
		data == $past(data, 1);
	endsequence
	
	sequence seq_error;
		//data error sequence
		(data != $past(data, 1) + 1) && (data != $past(data, 1) - 1) && (data != $past(data, 1));
	endsequence
	
	sequence seq_first_data;
		//first data sequence
		!$isunknown(data) && count == 1;
	endsequence
	
	//properties
	property PROP_VALID_OUTPUT;
		//if data is valid, we should get a valid output in next clock cycle
		@(posedge clk)
		disable iff(reset)
		!$isunknown(data) |=> !$isunknown({incr, decr, error}); 
	endproperty : PROP_VALID_OUTPUT
	
	property PROP_VALID_OUTPUT_COMB;
		//only one of the flags is allowed to be high in the output
		@(posedge clk)
		disable iff(reset)
		$onehot0({incr, decr, error});
	endproperty : PROP_VALID_OUTPUT_COMB

	property PROP_CORRECT_OUTPUT(rst, dataSeq, flagOut);
		//data seq produces correct output on next clock
		@(posedge clk)
		disable iff(rst)
		dataSeq |=> {incr, decr, error} == flagOut; 
	endproperty

	//Assertions
	ASRT_OUTPUT_VALID	:	assert property(PROP_VALID_OUTPUT);
	ASRT_ONEHOT0_OUT	:  	assert property(PROP_VALID_OUTPUT_COMB);
	ASRT_OUT_INCR		:	assert property(PROP_CORRECT_OUTPUT(reset || count==1, seq_incr, 3'b100));
	ASRT_OUT_DECR		:	assert property(PROP_CORRECT_OUTPUT(reset || count==1, seq_decr, 3'b010));
	ASRT_OUT_STABLE		:	assert property(PROP_CORRECT_OUTPUT(reset || count==1, seq_stable, 3'b000));
	ASRT_OUT_ERROR		:	assert property(PROP_CORRECT_OUTPUT(reset || count==1, seq_error, 3'b001));
	ASRT_OUT_FIRST_DATA :	assert property(PROP_CORRECT_OUTPUT(reset, seq_first_data, 3'b000));
	
	//coverage
	covergroup cg_counterDetect @(posedge clk);
		
		data_cp : coverpoint data;
		incr_cp : coverpoint incr;
		decr_cp : coverpoint decr;
		err_cp  : coverpoint error;
	
		//data transition coverpoint
		data_transition_cp : coverpoint data { 
			bins transitions[] = ( [0 : 2^4 - 1] => [0 : 2^4 - 1] );
		}
		
		//output combination coverpoint
		output_cross_cp : cross incr_cp, decr_cp, err_cp {
			illegal_bins C1 = output_cross_cp with (incr_cp == 0 && decr_cp == 1 && err_cp == 1);
			illegal_bins C2 = output_cross_cp with (incr_cp == 1 && decr_cp == 0 && err_cp == 1);
			illegal_bins C3 = output_cross_cp with (incr_cp == 1 && decr_cp == 1 && err_cp == 0);
			illegal_bins C4 = output_cross_cp with (incr_cp == 1 && decr_cp == 1 && err_cp == 1);
		}
		
	endgroup
	
	//coverage instance
	cg_counterDetect cov = new();
endinterface