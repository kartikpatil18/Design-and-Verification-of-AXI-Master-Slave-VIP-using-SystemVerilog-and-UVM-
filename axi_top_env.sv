class axi_top_env extends uvm_env;
	`uvm_component_utils(axi_top_env)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//master agent 
	axi_master_agent master_agent;
	//slave agent 
	axi_slave_agent slave_agent;
	//scoreboard 
	axi_scoreboard    axi_sco;
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		master_agent=axi_master_agent::type_id::create("master_agent",this);
		slave_agent=axi_slave_agent::type_id::create("slave_agent",this);
		axi_sco=axi_scoreboard::type_id::create("axi_sco",this);
	endfunction

       function void connect_phase(uvm_phase phase);
           super.connect_phase(phase);
	    master_agent.axi_m_mon.tlm_mon.connect(axi_sco.tlm_scor.analysis_export);
       endfunction 	   
endclass
