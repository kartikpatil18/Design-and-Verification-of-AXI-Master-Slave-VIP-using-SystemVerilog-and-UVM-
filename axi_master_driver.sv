class axi_master_driver extends uvm_driver#(axi_tx);
	`uvm_component_utils(axi_master_driver)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction
int  total_data_width_in_bytes,bytes_in_each_beat,address_reminder,unaligned_to_aligned_address,address_diff,narrow_transfer; 
     virtual axi_interface v_m_intf;
int wstrb_bit; 

//OVERLAPPING EN=1 this indicates overlaping transcation 
//INTERLEVING EN=1 Interleving transaction 
//
//if both are 1 Overlapping + interleving 
//if both are 0 non overlaping + non interleaving
bit OVERLAPPING_EN=0;
bit INTERLEAVING_EN=0;
mailbox mb=new();
int count;

typedef struct{
	axi_tx tx;
	int beat_sent;
	int total_beats;
	bit active;//if any transaction all beats are sent need to avoid those transaction from next 
	int next_id;
	} tx_tracker_t;

	tx_tracker_t pool[int];

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual axi_interface)::get(this,"","v_intf",v_m_intf);//poiting from vurtual interface to virtual interface
		//v_m_intf=v_intf=p_intf;
	endfunction 
    
	//step1 get random data from sequencer 
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		wait(v_m_intf.aresetn==1);//when reset=0 then only master will send request to slave(active low reset)
		if(OVERLAPPING_EN==0 && INTERLEAVING_EN==0)begin //non overlapping transaction
		forever begin
                      @(posedge v_m_intf.aclk);
		       seq_item_port.get_next_item(req);//inside master dirver we are recived ranom values pcket 
		       //we need put all random values to interfce 
		       drive_req_to_interface(req);
	               seq_item_port.item_done();	       
		end
	        end
		if(OVERLAPPING_EN==1 && INTERLEAVING_EN==0)begin //only overlapping transaction
                fork
			overlapping_write_address();//get_next_item 1 clock ccyle delay then item_done 
			overlapping_write_data();//when any data mailboc it will get and start write data chnnale 
                join
		end 
		if( OVERLAPPING_EN==1 && INTERLEAVING_EN==1)begin //overlapping + Interleving 
			fork
			overlapping_write_address();
		        interleaving_data();	
			join 
		end
	endtask

	task drive_req_to_interface(axi_tx req);
             //write only
	     if(req.w_r==WRITE_ONLY)begin 
		     write_address_channel(req);
		     write_data_channel(req);
		     write_response_channel(req);
	     end
	     //read only
	     if(req.w_r==READ_ONLY)begin 
		     read_address_channel(req);
		     read_data_channel(req);
	     end
	     //write then read
	     if(req.w_r==WRITE_THEN_READ)begin
		     write_address_channel(req);
		     write_data_channel(req);
		     write_response_channel(req);
		     read_address_channel(req);
		     read_data_channel(req);
	         end 
	     //write paralel 
	     if(req.w_r==WRITE_PARALLEL_READ)begin
		   fork
	           begin 
		     write_address_channel(req);
		     write_data_channel(req);
		     write_response_channel(req);
	           end
	           begin
		     read_address_channel(req);
		     read_data_channel(req);
	           end
		   join
	   end 
	endtask 

	task write_address_channel(axi_tx req);//it will send all write address channel random values to interface also maitaine same information untill awready come from slave (awvalid will wait untill awready come from slave)
	v_m_intf.awaddr<=req.awaddr;//100
	v_m_intf.awid<=req.awid;//random
	v_m_intf.awvalid<=req.awvalid;//1
	v_m_intf.awlen<=req.awlen;//3
	v_m_intf.awsize<=req.awsize;//2
	v_m_intf.awburst<=req.awburst;//1 (incrment transaction )
	v_m_intf.awprot<=req.awprot;//random 
	v_m_intf.awlock<=req.awlock;//random
	v_m_intf.awcache<=req.awcache;//random
	wait(v_m_intf.awready==1)//before sending one more request or address infromation wait untill current one need to recive slave with the help of awready get to know.
	@(posedge v_m_intf.aclk);
	  v_m_intf.awvalid<=0;
	endtask
	task write_data_channel(axi_tx req);
		v_m_intf.bready<=1;
		//we need to send all diffrent beats to interface one by one
		for (int i=0; i<=v_m_intf.awlen; i++)begin //number of beats
			v_m_intf.wdata<=req.wdata.pop_back();// get the data, after get remove data in that location
			//wid,wvalid,wstrb,wlast
			v_m_intf.wvalid<=req.wvalid;
			v_m_intf.wid<=req.wid;//random value
			//wstrb
			strobe_genrate(req);//narrow transfer, normal transfer 
			v_m_intf.wstrb<=req.wstrb;
			if(i==v_m_intf.awlen) v_m_intf.wlast<=1;
			//write data also need to wait untill wready come from
			//slave, once wready came then only master will genrte
			//another beats of data 
			wait(v_m_intf.wready==1);
		       @(posedge v_m_intf.aclk);//1clock ccyle delay
	              v_m_intf.wvalid<=0;
                      v_m_intf.wlast<=0;
		       req.awaddr = req.awaddr - (req.awaddr % (2** req.awsize));
                       req.awaddr = req.awaddr + (2 ** req.awsize);
  

		end
		
			//wsrtobe genration (aligned, unaligned, narrow transfer)
	endtask
	task write_response_channel(axi_tx req);//bready=1
		v_m_intf.bready<=1;
	endtask
	task read_address_channel(axi_tx req);
		//it will send all write address channel random values to interface also maitaine same information untill awready come from slave (awvalid will wait untill awready come from slave)
	v_m_intf.araddr<=req.araddr;//100
	v_m_intf.arid<=req.arid;//random
	v_m_intf.arvalid<=req.arvalid;//1
	v_m_intf.arlen<=req.arlen;//3
	v_m_intf.arsize<=req.arsize;//2
	v_m_intf.arburst<=req.arburst;//1 (incrment transaction )
	v_m_intf.arprot<=req.arprot;//random 
	v_m_intf.arlock<=req.arlock;//random
	v_m_intf.arcache<=req.arcache;//random
	wait(v_m_intf.arready==1)//before sending one more request or address infromation wait untill current one need to recive slave with the help of awready get to know.
		       @(posedge v_m_intf.aclk);//1clock ccyle delay
	 v_m_intf.arvalid<=0;

	endtask
	task read_data_channel(axi_tx req);
		v_m_intf.rready<=1;
	endtask 

	//wstrb genration one task task 
	//interleving one task
	//out of order transaction 

	//master driver send all random values to slave by using interface 
	
//awaddr=4    awsize=2 wdata=64bit   wstrb=1111_0000   narrow transfer
//awaddr=0    awsize=2 wdata=64bit    wstrb=0000_1111   narrow transfer
//
//awaddr=100   awsize=2   wdata=64bit   wstrb=1111_0000  narrow tramsfer
//
//awaddr=100  awsize=2 wdata=32bit   wstrb=4'b1111  normal transfder 
//
//
//awaddr=5   awsize=2  wdata=64bit    wstrb=1110_0000
//
//awaddr=246   awsize=2   wdata=64bit   wstrb=1100_0000
//
//awaddr=103   awsize=2   wdata=64bit   wstrb=1000_0000
//
//awaddr= 2   awsize=2   wdata=32bit   wstrb=1100
//
////8

	task strobe_genrate(axi_tx req);//unaligned(first best all bytes are not active and remaining beats all bytes are active), narrow transfer all beatss aall bytes not active(every beat some bytes and some bytes are inactive)
         //4 to 5 fromula
	  //wdata total size in bytes 
	  total_data_width_in_bytes = ($size(v_m_intf.wdata)/8);//4
          //how many bytes are active in each beat 
	  bytes_in_each_beat = (2**req.awsize);//awsize=2 4 bytes are active, awsize=3 8 bytes are active//4 
          //aligned address or unaligned address, if address is aligned then
	  //reminder 0, if address unaligned remainder not equals to 0
	  address_reminder = req.awaddr % total_data_width_in_bytes;//narrow transfer, not a aligned address formul//0
          //convert aligned address   //2%4 = 2
	  unaligned_to_aligned_address = req.awaddr - (req.awaddr % bytes_in_each_beat);//not narrow, normal transfer conversion
	                                //2 - 2 = 0
	  //below 2 formula mainly used to achive unaligned types of
	  //transaction (aligned address time no useful)
          //address diffrence number of byte location
	  address_diff = req.awaddr - unaligned_to_aligned_address; //2-0 //2
          //narrow transfer 
	  narrow_transfer = address_reminder - address_diff;//2-2//0

	  req.wstrb=0;//initualizing 

	  //aligned transaction 
	  if(req.awaddr % bytes_in_each_beat ==0)begin 
		  for(int j=0; j<bytes_in_each_beat; j++)begin //4 times   wstrb[4]=1  wstrb[5]=1 wstrb[6]=1 wstrb[7]=1
                    wstrb_bit = (address_reminder +j) % total_data_width_in_bytes;
		    req.wstrb[wstrb_bit]=1;//wstrb[4]=1  wstrb[5]=1  wstrb[6]=1  wstrb[7]=1
		                           //wstrb[0]=1   wstrb[1]=1  wstrb[2]
					   //=1  wstrb[3]=1   wstrb=0000_1111
					   //
					   //wstrb[4]=1 wstrb[5]=1 wstrb[6]=1
					   //wstrb[7]=1   wstrb=1111_0000
					   //
					   //wstrb[0]=1  wstrb[1]=1  wstrb[2]
					   //=1 estrb[3]=1   wstrb=4'b1111
	  end
	  
           end 
	  //unaligned transaction 
	  else begin 
		  for(int j=address_reminder; j<(narrow_transfer + bytes_in_each_beat); j++)begin 
			  req.wstrb[j]=1;//j=5,j=6,j=7  wstrb[5]=1  wstbr[6]=1 estrb[7]=1 wstrb=1110_0000
			                   //wstrb[6]=1 wstrb[7]=1
					   //wstrb=1100_0000
					   //
					   //wstrb[7]=1   wstrb=1000_0000
					   //
					   //wstrb[2]=1  wstrb[3]=1
					   //wstrb=1100
		  end
	  end
	endtask

//OVERLAPPING TRANSACTION TASK
task overlapping_write_address();
	forever begin 
		seq_item_port.get_next_item(req);//10,   100
		if(req.w_r==WRITE_ONLY)begin
	v_m_intf.awaddr<=req.awaddr;//100
	v_m_intf.awid<=req.awid;//random
	v_m_intf.awvalid<=req.awvalid;//1
	v_m_intf.awlen<=req.awlen;//3
	v_m_intf.awsize<=req.awsize;//2
	v_m_intf.awburst<=req.awburst;//1 (incrment transaction )
	v_m_intf.awprot<=req.awprot;//random 
	v_m_intf.awlock<=req.awlock;//random
	v_m_intf.awcache<=req.awcache;//random
	wait(v_m_intf.awready==1)//before sending one more request or address infromation wait untill current one need to recive slave with the help of awready get to know.
        //we need to store this req to mailbox 
        mb.put(req);// 
end//write_only
    if(req.w_r==READ_ONLY)begin //read overlapping 
	    read_address_channel(req);
	    read_data_channel(req);

    end
    	@(posedge v_m_intf.aclk);
	  v_m_intf.awvalid<=0;
	  seq_item_port.item_done();
  end
  endtask


	task overlapping_write_data();
		v_m_intf.bready<=1;//bready=1 //when ,aster send address its ready to recive response 
		forever begin
		axi_tx req;
		mb.get(req);
		//we need to send all diffrent beats to interface one by one
		for (int i=0; i<=req.awlen; i++)begin //number of beats
			v_m_intf.wdata<=req.wdata.pop_back();// get the data, after get remove data in that location
			//wid,wvalid,wstrb,wlast
			v_m_intf.wvalid<=req.wvalid;
			v_m_intf.wid<=req.wid;//random value
			//wstrb
			strobe_genrate(req);//narrow transfer, normal transfer 
			v_m_intf.wstrb<=req.wstrb;
			if(i==v_m_intf.awlen) v_m_intf.wlast<=1;
			//write data also need to wait untill wready come from
			//slave, once wready came then only master will genrte
			//another beats of data 
			wait(v_m_intf.wready==1);
		       @(posedge v_m_intf.aclk);//1clock ccyle delay
	              v_m_intf.wvalid<=0;
                      v_m_intf.wlast<=0;
		      //next beat wstrb caclulation using below formayl
		      //unaligned to aligned
		       req.awaddr = req.awaddr - (req.awaddr % (2** req.awsize));
		       //next beat strat address 
                       req.awaddr = req.awaddr + (2 ** req.awsize);
  

		end
	end
endtask


task interleaving_data();
	v_m_intf.bready<=1;
	forever begin 
//storing all the rewquest from sequence to struct 
collect_new_transactions();
//sortlist all the pool array indexes also ignore if active=0 get active
//indexes 
//randomize the index values then send beats to interface
send_interleave_data(); 
   end 	
endtask

task collect_new_transactions();// 

	tx_tracker_t tracker;


	while(mb.num() >0)begin 
		axi_tx new_tx;
		mb.get(new_tx);// we need to store all write address and write data to struct pkt 
		tracker.tx=new_tx;
		tracker.beat_sent=0;
		tracker.total_beats= new_tx.awlen+1;
		tracker.active=1;
		tracker.next_id = count;

		pool[count]= tracker;//

		`uvm_info("INTERLEAVE",$sformatf("ADDED transaction awaddr=%h, beats_sent=%h total_beats=%h", pool[count].tx.awaddr, pool[count].beat_sent, pool[count].total_beats), UVM_LOW); 
	       count++;	
	end
endtask

task get_active_index(ref int active_list[$]);
	int idx[$];
	active_list.delete(); 
         idx = pool.find_index() with(item==item);//every indexes in pool will store to idx calrible {0,1,2,3)
	 //we want to sortlist active idx only
	 foreach(idx[i])begin 
		 if(pool[idx[i]].active==1 )begin 
			 active_list.push_back(idx[i]);  // {0,1,3}
		 end
	 end	 
endtask


task send_interleave_data();
	int active_idx[$];
	int selected_id;
	tx_tracker_t selected_tracker;
	get_active_index(active_idx);


	//if active idx when were size is not greter than is equals to 1 it
	//dont go for next lines of the code 
        if(active_idx.size() ==0)begin 
	 @(posedge v_m_intf.aclk);
        return;
        end//this task will stop will exit from this line, next lines dont executed 	

       
	//we need to randomize indexes 
	selected_id=active_idx[$urandom_range(0, active_idx.size() -1)];  //active_idx[$urandom_range(0,2)] 
       	
        selected_tracker = pool[selected_id];
    
	strobe_genrate(selected_tracker.tx);
	v_m_intf.wdata<= selected_tracker.tx.wdata.pop_front();
	v_m_intf.wid<=selected_tracker.tx.wid;
	v_m_intf.wvalid<=selected_tracker.tx.wvalid;
	v_m_intf.wstrb<=selected_tracker.tx.wstrb;
	//awlen=3  when we want wlast=1 last beat or 4th beat time

	if(selected_tracker.beat_sent == (selected_tracker.total_beats-1))begin  // 3
		v_m_intf.wlast<=1;
		selected_tracker.active=0;
	end
	selected_tracker.beat_sent++;

	wait(v_m_intf.wready==1);
		       @(posedge v_m_intf.aclk);//1clock ccyle delay
	              v_m_intf.wvalid<=0;
                      v_m_intf.wlast<=0;
		       selected_tracker.tx.awaddr =  selected_tracker.tx.awaddr - ( selected_tracker.tx.awaddr % (2**  selected_tracker.tx.awsize));
                        selected_tracker.tx.awaddr =  selected_tracker.tx.awaddr + (2 **  selected_tracker.tx.awsize);

	
  
        pool[selected_id]=selected_tracker;
endtask



endclass //strobe logic   1hr needed 


//slave driver   3hr  sunday ---  scoreboard, inteeleving , overlpaing 



