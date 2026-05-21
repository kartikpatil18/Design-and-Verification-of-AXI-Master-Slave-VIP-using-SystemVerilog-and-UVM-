class axi_slave_agent extends uvm_agent;
	`uvm_component_utils(axi_slave_agent)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
   //driver 
   axi_slave_driver axi_s_drv;
   //monitor 
   axi_slave_monitor  axi_s_mon;


   function void build_phase(uvm_phase phase);
	   super.build_phase(phase);
	   axi_s_drv=axi_slave_driver::type_id::create("axi_s_drv",this);
	   axi_s_mon=axi_slave_monitor::type_id::create("axi_s_mon",this);
   endfunction 
endclass
