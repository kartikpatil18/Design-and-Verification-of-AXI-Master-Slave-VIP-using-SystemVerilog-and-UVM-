class axi_slave_monitor extends uvm_monitor;
		`uvm_component_utils(axi_slave_monitor)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 

//every clock cycle will reive all signals values then put into packet then
//send to cov and sco blocks 

endclass
