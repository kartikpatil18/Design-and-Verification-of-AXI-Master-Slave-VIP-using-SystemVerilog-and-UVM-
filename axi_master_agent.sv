class axi_master_agent extends uvm_agent;
	`uvm_component_utils(axi_master_agent)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
//sequencer 
axi_master_sequencer  axi_m_seqr;
//driver 
axi_master_driver    axi_m_drv;
//monitor 
axi_master_monitor    axi_m_mon;


function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	axi_m_seqr=axi_master_sequencer::type_id::create("axi_m_seqr",this);
	axi_m_drv=axi_master_driver::type_id::create("axi_m_drv",this);
	axi_m_mon=axi_master_monitor::type_id::create("axi_m_mon",this);
endfunction 

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	//sequencer to driver connection 
	axi_m_drv.seq_item_port.connect(axi_m_seqr.seq_item_export);
endfunction 
endclass
