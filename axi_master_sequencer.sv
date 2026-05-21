class axi_master_sequencer extends uvm_sequencer#(axi_tx);
	`uvm_component_utils(axi_master_sequencer)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
endclass 
