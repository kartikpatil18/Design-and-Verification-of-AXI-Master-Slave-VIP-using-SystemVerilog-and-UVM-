class axi_top_sequence extends uvm_sequence#(axi_tx);
	`uvm_object_utils(axi_top_sequence)
	function new(string name="");
		super.new(name);
	endfunction 
	//moe gnric configurations we need to incldue (we need to genrate
	//address range from 0 to 2000 only this will be applicable all
	//sequenced 
endclass

//---------------------------------------------------------------------------------------------
//Sequence1
//multiple write and read bring up sequence (Aligned address, full strobe
//enable, alwne=3)
class bring_up_sequence extends axi_top_sequence;
	`uvm_object_utils(bring_up_sequence)
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ; req.awaddr==8; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==1; req.arvalid==1;});
	endtask
endclass
//-----------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------
//Sequence2
//INCREMNT MULTIPLE WRITE AND READ TRANSACTION WITH ALIGNED ADDRESS 
//10 write and read transaction   64 bit aligned address 
class increment_aligned_sequence extends axi_top_sequence;
	`uvm_object_utils(increment_aligned_sequence)
	int a;
	int size;
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ;awaddr<9000; (awaddr % 2**awsize)==0; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==1; req.arvalid==1;});

	
	       end
	endtask
endclass
//-----------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------
//Sequence3
//INCREMNT MULTIPLE WRITE AND READ TRANSACTION WITH ALIGNED ADDRESS 
//10 write and read transaction , narrow transfer  (wdata size 64 bit awsize 0,
//1,2)
class increment_aligned_narrow_sequence extends axi_top_sequence;
	`uvm_object_utils(increment_aligned_narrow_sequence)
	int a;
	int size;
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ;awaddr<9000; (awaddr % 2**awsize)==0; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize<=2; req.awlen==3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==1; req.arvalid==1;});
	       end
	endtask
endclass
//-----------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------
//Sequence4
//INCREMNT MULTIPLE WRITE AND READ TRANSACTION WITH UNALIGNED ADDRESS 
//10 write and read transaction 
class increment_unaligned_sequence extends axi_top_sequence;
	`uvm_object_utils(increment_unaligned_sequence)
	int a;
	int size;
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ;awaddr<9000; (awaddr % 2**awsize)!=0; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==1; req.arvalid==1;});
	       end
	endtask
endclass
//-----------------------------------------------------------------------------------------------------------------



//-----------------------------------------------------------------------------------------------
//Sequence5
//INCREMNT MULTIPLE WRITE AND READ TRANSACTION WITH UNALIGNED ADDRESS
//& ALIGNED ADDRESS, WITHOUT NARROW, WITH NARROW  
//10 write and read transaction 
class increment_genric_sequence extends axi_top_sequence;
	`uvm_object_utils(increment_genric_sequence)
	int a;
	int size;
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ;awaddr<9000; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize<=3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==1; req.arvalid==1;});
	       end
	endtask
endclass
//-----------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------
//Sequence6 Overlapping transaction:
//INCREMNT MULTIPLE WRITE AND READ TRANSACTION WITH ALIGNED ADDRESS 
//10 write and read transaction   64 bit aligned address overlapping
//transaction 
class overlaping_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(overlaping_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<10; i++)begin 
		a=$urandom_range(0,9000000);	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	       #5000;
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==READ_ONLY; req.araddr==b[i]; req.arvalid==1; req.arburst==tx[i].awburst; req.arsize==tx[i].awsize; req.arlen==tx[i].awlen;});
	       end
	endtask
endclass
//------------------------------------------------------------------------------------------------------------------------
//Sequence7 Overlapping transaction: 100 write and read 
//transaction 
class overlaping_100_w_r_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(overlaping_100_w_r_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<100; i++)begin 
		a=$urandom_range(0,9000000);	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	       #5000;
		for(int i=0; i<100; i++)begin 	
		`uvm_do_with(req,{req.w_r==READ_ONLY; req.araddr==b[i]; req.arvalid==1; req.arburst==tx[i].awburst; req.arsize==tx[i].awsize; req.arlen==tx[i].awlen;});
	       end
	endtask
endclass

//-----------------------------------------------------------------------------------------------------------
//TESTCASE 8: INTERLEAVING WRITE ONLY
class interleaving_write_only_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(interleaving_write_only_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<10; i++)begin 
		a=$urandom_range(0,9000000);	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	endtask
endclass
//--------------------------------
//
//TESTCASE9 : 10 write and read interleving + out of order testcase
//+ overlapping + increment + aligned + unaligned

class interleaving_wr_rd_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(interleaving_wr_rd_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<10; i++)begin 
		a=$urandom_range(0,9000000);	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	       #5000;
		for(int i=0; i<10; i++)begin 	
		`uvm_do_with(req,{req.w_r==READ_ONLY; req.araddr==b[i]; req.arvalid==1; req.arburst==tx[i].awburst; req.arsize==tx[i].awsize; req.arlen==tx[i].awlen;});
	       end
	endtask
endclass


//-------------------------------------------------------
//TESTCASE10 : 100 write and read interleving + out of order testcase
//+ overlapping + increment + aligned + unaligned

class interleaving_100_wr_rd_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(interleaving_100_wr_rd_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<100; i++)begin 
		a=$urandom_range(0,9000000);	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==1; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	       #5000;
		for(int i=0; i<100; i++)begin 	
		`uvm_do_with(req,{req.w_r==READ_ONLY; req.araddr==b[i]; req.arvalid==1; req.arburst==tx[i].awburst; req.arsize==tx[i].awsize; req.arlen==tx[i].awlen;});
	       end
	endtask
endclass


//----------------------------------------------------------------------------------

//Sequence 11
////Sequence1
//multiple write and read bring up sequence (Aligned address, full strobe
//enable, alwne=3)
class wrap_wr_rd_sequence extends axi_top_sequence;
	`uvm_object_utils(wrap_wr_rd_sequence)
	function new(string name="");
		super.new(name);
	endfunction 
	task body();
		`uvm_do_with(req,{req.w_r==WRITE_THEN_READ; req.awaddr==8; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==2; req.awsize==3; req.awlen==3; req.araddr==req.awaddr; req.arlen==req.awlen; req.arsize==req.awsize; req.arburst==2; req.arvalid==1;});
	endtask
endclass

//---------------------------------------------------------------------------------

//TESTCASE12  wrap transaction 100 write and read, overlapping, inteleving,
//out of order
class wrap_100_wr_rd_sequence extends axi_top_sequence;//overlapping+ aligned+unaligned+incremnt 
	`uvm_object_utils(wrap_100_wr_rd_sequence)

		function new(string name="");
		super.new(name);
	endfunction 
	axi_tx tx[$];
	int a;
	int b[$];
	task body();
		for(int i=0; i<100; i++)begin 
		a=$urandom_range(0,9000000);
		a= a- (a%(2**3)); 	
		`uvm_do_with(req,{req.w_r==WRITE_ONLY; awaddr==a; req.awvalid==1; req.wvalid==1; req.wid==awid; req.awburst==2; req.awsize==3; req.awlen==3;});
		tx.push_back(req);//
	       b[i]=a;	
	       end
	       #5000;
		for(int i=0; i<100; i++)begin 	
		`uvm_do_with(req,{req.w_r==READ_ONLY; req.araddr==b[i]; req.arvalid==1; req.arburst==tx[i].awburst; req.arsize==tx[i].awsize; req.arlen==tx[i].awlen;});
	       end
	endtask
endclass


