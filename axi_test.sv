class axi_top_test extends uvm_test;
	`uvm_component_utils(axi_top_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 

	//we need to include axi_top_env 
	
	axi_top_env env;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//object crearetion 
		env=axi_top_env::type_id::create("env",this);
	endfunction 

endclass

//-------------------------------------------------------------------------------------
//TESTCASE1
//SCOREBORD TESTED 
class bring_up_test extends axi_top_test;
	`uvm_component_utils(bring_up_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		bring_up_sequence seq;
		seq=bring_up_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#200;
		phase.drop_objection(this);
	endtask
endclass
//---------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
//TESTCASE2: INCREMENT TRANSACTION, MULTIPLE WR_RD, 64 bit aligned address,
//all wstrb will be high 
//SCOREBORD TESTED
class increment_multiple_wr_rd_aligned_test extends axi_top_test;
	`uvm_component_utils(increment_multiple_wr_rd_aligned_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		increment_aligned_sequence seq;
		seq=increment_aligned_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#200;
		phase.drop_objection(this);
	endtask
endclass


//-----------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
//TESTCASE3: INCREMENT TRANSACTION, MULTIPLE WR_RD, narrow transfer,
//all wstrb will be high 
//SCOREBOARD TESTED 
class increment_multiple_wr_rd_aligned_narrow_test extends axi_top_test;
	`uvm_component_utils(increment_multiple_wr_rd_aligned_narrow_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		increment_aligned_narrow_sequence seq;
		seq=increment_aligned_narrow_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#200;
		phase.drop_objection(this);
	endtask
endclass


//-----------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
//TESTCASE4: INCREMENT TRANSACTION, MULTIPLE WR_RD, narrow transfer,
//all wstrb will be high 
//SCOREBAORD TESTED 
class increment_multiple_wr_rd_unaligned_test extends axi_top_test;
	`uvm_component_utils(increment_multiple_wr_rd_unaligned_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		increment_unaligned_sequence seq;
		seq=increment_unaligned_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#200;
		phase.drop_objection(this);
	endtask
endclass


//-----------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
//TESTCASE5: INCREMENT TRANSACTION, MULTIPLE WR_RD, narrow transfer,
//all wstrb will be high
//SCOREBOARD TESTED  
class increment_genric_test extends axi_top_test;
	`uvm_component_utils(increment_genric_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		increment_genric_sequence seq;
		seq=increment_genric_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#200;
		phase.drop_objection(this);
	endtask
endclass


//-----------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
//TESTCASE6: INCREMENT TRANSACTION, MULTIPLE WR_RD, narrow transfer,
//OVERLAPPING TRANSACTION
//all wstrb will be high 
//SCOREBOARD TESTED 
class overlapping_test extends axi_top_test;
	`uvm_component_utils(overlapping_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		overlaping_sequence seq;
		seq=overlaping_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#10000;
		phase.drop_objection(this);
	endtask
endclass


//----------------------------------------------------------
//
//TESTCASE 7: 
//SCOREBOARD TESTED 
class overlapping_100_w_r_test extends axi_top_test;
	`uvm_component_utils(overlapping_100_w_r_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		overlaping_100_w_r_sequence seq;
		seq=overlaping_100_w_r_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#10000;//without this delays, simultion will stop in mid only, but that is not ny functionality issues we cant see some of last data in waveform, to observe that read data we will add some delay before drop objection it will increase simultion time then will proper all read data.
		phase.drop_objection(this);
	endtask
endclass
//----------------------------------------------------------------
//TESTCASE 8 // INSIDE MASTER DRIVER NEED TO ENABLE INTERLEVING and
//OVERLAPPING then only this test will work
class interleaving_write_only_test extends axi_top_test;
	`uvm_component_utils(interleaving_write_only_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		interleaving_write_only_sequence seq;
		seq=interleaving_write_only_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#1000;
		phase.drop_objection(this);
	endtask
endclass

//----------------------------------------------------------------------------------------------------------------------------
//TESTCASE 9 // 
class interleaving_wr_rd__test extends axi_top_test;
	`uvm_component_utils(interleaving_wr_rd__test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		interleaving_wr_rd_sequence seq;
		seq=interleaving_wr_rd_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#1000;
		phase.drop_objection(this);
	endtask
endclass

//-----------------------------------------------------------------------------------------
//TESTCASE 10
class interleaving_100_wr_rd__test extends axi_top_test;
	`uvm_component_utils(interleaving_100_wr_rd__test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		interleaving_100_wr_rd_sequence seq;
		seq=interleaving_100_wr_rd_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#10000;
		phase.drop_objection(this);
	endtask
endclass

//--------------------------------------------------------------------------------------
//TESTCASE 11

class wrap_wr_rd_test extends axi_top_test;
	`uvm_component_utils(wrap_wr_rd_test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		wrap_wr_rd_sequence seq;
		seq=wrap_wr_rd_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#1000;
		phase.drop_objection(this);
	endtask
endclass

//--------------------------------------------------------------------------------
//TESTCASE 12
class wrap_100_wr_rd__test extends axi_top_test;
	`uvm_component_utils(wrap_100_wr_rd__test);
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction 
	//we need to connect specific sequence to sequencer 
	task run_phase(uvm_phase phase);
		wrap_100_wr_rd_sequence seq;
		seq=wrap_100_wr_rd_sequence::type_id::create("seq");

		phase.raise_objection(this);
		seq.start(env.master_agent.axi_m_seqr);//M_sequencer
		#10000;
		phase.drop_objection(this);
	endtask
endclass

