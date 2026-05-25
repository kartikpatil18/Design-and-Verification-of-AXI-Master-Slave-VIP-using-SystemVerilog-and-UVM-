//Slave VIP acts as normal memeory(INCR), cacahe memeory(WRAP) , fifo type of memeory (FIXED TRANSACTION)
//
//Recive request from master and w.r.t request it will send back response 
//ex: it will recive write request(write address or write data), w.r.t that it
//will send write response, in read master send read address request slave
//will send back read data along with response. (between master snd slave
//using interface block(conection done by using interface)

class axi_slave_driver extends uvm_driver#(axi_tx);
	`uvm_component_utils(axi_slave_driver)
	function new(string name="", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	axi_tx  wr_tx[int];
	axi_tx  rd_tx[int];
//We need to get pointd virtual interface top module 
virtual axi_interface v_s_intf;
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	uvm_config_db#(virtual axi_interface)::get(this,"","v_intf",v_s_intf);
endfunction
int wdata_burst_width_in_bytes;
int count;
int address_remainder;
int range;
int temp_rd_id;
int k;
int wrap_boundry;
int rd_k;
int rd_wrap_boundry;
int address_n;
int rd_address_n;

//Normal memeory incrment transaction 
reg [7:0] mem[10000000];//axi byte based transaction, each location 8bits of data only possible becuse of that each memeory location with is 8bit only.

//Ccache memeory  wrap type of transaction 

//fifo memeory   fixed type of transaction 


//it will check every clock cycle any clock cycle awresetn=0(acive low) in that time all
//outputs move to initial values or defualt values 
task run_phase(uvm_phase phase);
	super.run_phase(phase);
	forever begin
	 @(posedge v_s_intf.aclk);
	     v_s_intf.wready<=0;
	     v_s_intf.bvalid<=0;
	     v_s_intf.rlast<=0;
	     v_s_intf.rvalid<=0;
           if(v_s_intf.aresetn==0)begin//reset state slave is not ready to recive and not ready to send any request or response 
		   v_s_intf.awready<=0;//slave is not ready to recive any address
		   v_s_intf.wready<=0;//slave is not ready to recive any data from master
		   v_s_intf.bvalid<=0;//slave not sending any reponse 
		   v_s_intf.bid<=0;
		   v_s_intf.bresp<=0;
		   v_s_intf.arready<=0;
		   v_s_intf.rdata<=0;
		   v_s_intf.rvalid<=0;
		   v_s_intf.rlast<=0;
		   v_s_intf.rid<=0;
		   v_s_intf.rresp<=0;
	   end
           else begin //working state 
                  //1.write data channel possible
		  if(v_s_intf.awvalid==1)begin //master sending valid write address request
			 v_s_intf.awready<=1; //slave sending am ready to recive valid address & control signals
//out_of_order, overlapping, write paralell readf ans interleving
                        v_s_intf.wready<=1;//before write data slave is ready to recive data 
                   wr_tx[v_s_intf.awid]=new();//wr_tx[10]
		   wr_tx[v_s_intf.awid].awaddr = v_s_intf.awaddr;
		   wr_tx[v_s_intf.awid].awlen = v_s_intf.awlen;
		   wr_tx[v_s_intf.awid].awsize = v_s_intf.awsize;
		   wr_tx[v_s_intf.awid].awburst = v_s_intf.awburst;
		   wr_tx[v_s_intf.awid].awcache = v_s_intf.awcache;
		   wr_tx[v_s_intf.awid].awlock = v_s_intf.awlock;
		   wr_tx[v_s_intf.awid].awid = v_s_intf.awid;
		   wr_tx[v_s_intf.awid].awprot = v_s_intf.awprot;   
		  		  end
		 		  if(v_s_intf.wvalid==1)begin //master sending valid write data request 
			  v_s_intf.wready<=1;
			    wdata_burst_width_in_bytes = ($size(v_s_intf.wdata)/8); //4
			    $display("Write awaddr=%h wdata=%h time=%t", wr_tx[v_s_intf.wid].awaddr, v_s_intf.wdata,$time);
              
			  //INCR TRANSACTION 
			  if(wr_tx[v_s_intf.wid].awburst==1)begin  
				  //how many beats of data we need to genrate 	
                                    count=0;
                                    for(int i=0; i<=wdata_burst_width_in_bytes; i++)begin //4 times
                                      if(v_s_intf.wstrb[i]==1)begin//wstrb 8bit 
                                        mem[wr_tx[v_s_intf.wid].awaddr+count]=v_s_intf.wdata[i*8 +:8];
					//mem[4]=44 mem[5]=33 mem[6]=22 mem[7]
					//=11  mem[8] mem[9] mem[10]  mem[11
                                        count=count+1; //next byte slave neeed to icnremnt              
				  end
			  end 
			   //Convert unaligned to aligned address 
			   //awaddr = awaddr - (awaddr % 2^awsize); 
                 wr_tx[v_s_intf.wid].awaddr= wr_tx[v_s_intf.wid].awaddr - (wr_tx[v_s_intf.wid].awaddr % 2**wr_tx[v_s_intf.wid].awsize); 
                 wr_tx[v_s_intf.wid].awaddr= wr_tx[v_s_intf.wid].awaddr + 2**wr_tx[v_s_intf.wid].awsize;
		 wr_tx[v_s_intf.wid].byte_count= wr_tx[v_s_intf.wid].byte_count +1; 

		if(v_s_intf.wlast==0)begin //slave no need to send  response 
				v_s_intf.bvalid<=1'b0;
			        v_s_intf.bid<=0;
			end
		 if(wr_tx[v_s_intf.wid].byte_count == wr_tx[v_s_intf.wid].awlen +1)begin//this is the last beat of specific ID         
			 if(v_s_intf.wlast ==1)begin //write response chnnale 
                            //3.Write response channel
			    $display("wid slave driver =%h", v_s_intf.wid);
				v_s_intf.bid<=v_s_intf.wid;//slave  
				v_s_intf.bresp<=2'b00;//ok reponse 
				v_s_intf.bvalid<=1'b1;
			        wait(v_s_intf.bready==1);//next transaction data also need to wait
			end
		end 
                  end // burst

		  //WRAP TYPE OF TRANSACTION 
		  if(wr_tx[v_s_intf.wid].awburst==2)begin //INCR TRANSACTION  wr_tx[500].awburst
                    //step1: check adddredd is aligned 
		    if(wr_tx[v_s_intf.wid].awaddr % (2 ** wr_tx[v_s_intf.wid].awsize)==0)begin 
	            //step2: number of beats is eqauls to 2,4,8 or 16 

		    if(	wr_tx[v_s_intf.wid].awlen==1 || wr_tx[v_s_intf.wid].awlen==3 || wr_tx[v_s_intf.wid].awlen==7 || wr_tx[v_s_intf.wid].awlen==15)begin 
		    //step3 wrap boundry 
		    k=(	 wr_tx[v_s_intf.wid].awaddr/ ( (2 ** wr_tx[v_s_intf.wid].awsize) *  wr_tx[v_s_intf.wid].awlen+1));
		    wrap_boundry= k * ( (2 ** wr_tx[v_s_intf.wid].awsize) *  ( wr_tx[v_s_intf.wid].awlen+1));

                    //Step4: address_n
		     address_n= wrap_boundry + ( (2 ** wr_tx[v_s_intf.wid].awsize) *   (wr_tx[v_s_intf.wid].awlen+1));


				  //how many beats of data we need to genrate 	
                                    count=0;
                                    for(int i=0; i<=wdata_burst_width_in_bytes; i++)begin //4 times
                                      if(v_s_intf.wstrb[i]==1)begin//wstrb 8bit 
                                        mem[wr_tx[v_s_intf.wid].awaddr+count]=v_s_intf.wdata[i*8 +:8];
					//mem[4]=44 mem[5]=33 mem[6]=22 mem[7]
					//=11  mem[8] mem[9] mem[10]  mem[11
                                        count=count+1; //next byte slave neeed to icnremnt              
				  end
			  end 
                 wr_tx[v_s_intf.wid].awaddr= wr_tx[v_s_intf.wid].awaddr + 2**wr_tx[v_s_intf.wid].awsize;

                 if(wr_tx[v_s_intf.wid].awaddr == address_n)
			  wr_tx[v_s_intf.wid].awaddr = wrap_boundry;



		 wr_tx[v_s_intf.wid].byte_count= wr_tx[v_s_intf.wid].byte_count +1; 

		if(v_s_intf.wlast==0)begin //slave no need to send  response 
				v_s_intf.bvalid<=1'b0;
			        v_s_intf.bid<=0;
			end
		 if(wr_tx[v_s_intf.wid].byte_count == wr_tx[v_s_intf.wid].awlen +1)begin//this is the last beat of specific ID         
			 if(v_s_intf.wlast ==1)begin //write response chnnale 
                            //3.Write response channel
			    $display("wid slave driver =%h", v_s_intf.wid);
				v_s_intf.bid<=v_s_intf.wid;//slave  
				v_s_intf.bresp<=2'b00;//ok reponse 
				v_s_intf.bvalid<=1'b1;
			        wait(v_s_intf.bready==1);//next transaction data also need to wait
		
			end
		end 
	        end//number beats 
	        end//aligned formula 
                  end // burst

		  end//wvalid

                  //4.Read Address channel
	   if(v_s_intf.arvalid==1)begin //araddr=4   arsize=2   arlen=3   arid=10   arburst=1     arid=20	   
		rd_tx[v_s_intf.arid]=new();//    rd_tx[10]=new();      rd_tx[20]=new();          
		rd_tx[v_s_intf.arid].araddr =v_s_intf.araddr; //wr_tx[10].awaddr                
		rd_tx[v_s_intf.arid].arlen =v_s_intf.arlen;//from interface 
		rd_tx[v_s_intf.arid].arsize =v_s_intf.arsize;
		rd_tx[v_s_intf.arid].arlock =v_s_intf.arlock;
		rd_tx[v_s_intf.arid].arprot =v_s_intf.arprot;
		rd_tx[v_s_intf.arid].arcache =v_s_intf.arcache;
		rd_tx[v_s_intf.arid].arburst =v_s_intf.arburst; 
		rd_tx[v_s_intf.arid].arid =v_s_intf.arid; 
		   v_s_intf.arready<=1;
		//firstvtransaction all address and control infromation
		//avilable in wr_tx[10] packet 
		   end
//araddr=4   arsize=2  arlen=3   arburst=1   arid=10

//araddr=6 

//5.read data channel
   if(rd_tx.size()>0) begin //some read address requests are avilable  then only our slave send read data & response  to master 
 v_s_intf.rlast<=0;	   
	 //  rd_tx.shuffule();  will enable to read out of order transaction 
	//read same order 
      rd_tx.first(temp_rd_id);

      //Incriment read transaction 
      if(rd_tx[temp_rd_id].arburst==1)begin 
		  //Convert unaligned to aligned address  
             	  //   awaddr=2  awsize=2   remainder =2    awsize=2  awaddr=7   3
	          address_remainder = (rd_tx[temp_rd_id].araddr % (2**rd_tx[temp_rd_id].arsize));//0 
	          range = (2**rd_tx[temp_rd_id].arsize) - address_remainder;//4-0
                  count=0;
		  v_s_intf.rdata=0;
                  for(int i=0; i< range; i++)begin //4 time 0 to 3  i<2
                  v_s_intf.rdata[i*8 +:8]=mem[rd_tx[temp_rd_id].araddr+count];//reading from memeory//mem[1000] mem[1001] 
                  count=count+1;//rdata[7:0]=mem[2+0] rdata[15:8] =mem[2+1]
                  end  
                  
		  v_s_intf.rresp<=2'b00;//ok response 
		  v_s_intf.rid<=temp_rd_id; 
		  v_s_intf.rvalid<=1; 
		  $display("Read araddr=%h rdata=%h time=%t",rd_tx[temp_rd_id].araddr, v_s_intf.rdata,$time);

		  //convert unaligned address to aligned 
                  rd_tx[temp_rd_id].araddr= rd_tx[temp_rd_id].araddr - (rd_tx[temp_rd_id].araddr % 2**rd_tx[temp_rd_id].arsize);//0
		 //Next beat start address 
                 rd_tx[temp_rd_id].araddr= rd_tx[temp_rd_id].araddr + 2**rd_tx[temp_rd_id].arsize;//4
		 //----------------------------------------------	
      rd_tx[temp_rd_id].read_byte_count= rd_tx[temp_rd_id].read_byte_count+1;
      if(rd_tx[temp_rd_id].read_byte_count == rd_tx[temp_rd_id].arlen+1)begin
	      v_s_intf.rlast<=1;
	      rd_tx.delete(temp_rd_id);
      end
	
      end//arburst

       //WRAP TRANSACTION 
      if(rd_tx[temp_rd_id].arburst==2)begin 

                    //step1: check adddredd is aligned 
		    if(rd_tx[temp_rd_id].araddr % (2 ** rd_tx[temp_rd_id].arsize)==0)begin 
	            //step2: number of beats is eqauls to 2,4,8 or 16 
		    if(	rd_tx[temp_rd_id].arlen==1 || rd_tx[temp_rd_id].arlen==3 || rd_tx[temp_rd_id].arlen==7 || rd_tx[temp_rd_id].arlen==15)begin 
		    //step3 wrap boundry 
		    rd_k=(	 rd_tx[temp_rd_id].araddr/ ( (2 ** rd_tx[temp_rd_id].arsize) *   (rd_tx[temp_rd_id].arlen+1)));
		    rd_wrap_boundry= k * ( (2 ** rd_tx[temp_rd_id].arsize) *   (rd_tx[temp_rd_id].arlen+1));

                    //Step4: address_n
		     rd_address_n= rd_wrap_boundry + ( (2 ** rd_tx[temp_rd_id].arsize) *   (rd_tx[temp_rd_id].arlen+1));

		  //Convert unaligned to aligned address  
             	  //   awaddr=2  awsize=2   remainder =2    awsize=2  awaddr=7   3
	          address_remainder = (rd_tx[temp_rd_id].araddr % (2**rd_tx[temp_rd_id].arsize));//0 
	          range = (2**rd_tx[temp_rd_id].arsize) - address_remainder;//4-0
                  count=0;
		  v_s_intf.rdata=0;
                  for(int i=0; i< range; i++)begin //4 time 0 to 3  i<2
                  v_s_intf.rdata[i*8 +:8]=mem[rd_tx[temp_rd_id].araddr+count];//reading from memeory//mem[1000] mem[1001] 
                  count=count+1;//rdata[7:0]=mem[2+0] rdata[15:8] =mem[2+1]
                  end  
                  
		  v_s_intf.rresp<=2'b00;//ok response 
		  v_s_intf.rid<=temp_rd_id; 
		  v_s_intf.rvalid<=1; 
		  $display("Read araddr=%h rdata=%h time=%t",rd_tx[temp_rd_id].araddr, v_s_intf.rdata,$time);

		  //convert unaligned address to aligned 
                  rd_tx[temp_rd_id].araddr= rd_tx[temp_rd_id].araddr - (rd_tx[temp_rd_id].araddr % 2**rd_tx[temp_rd_id].arsize);//0
		 //Next beat start address 
                 rd_tx[temp_rd_id].araddr= rd_tx[temp_rd_id].araddr + 2**rd_tx[temp_rd_id].arsize;//4
		 //----------------------------------------------

		 if(rd_tx[temp_rd_id].araddr == rd_address_n)
			  rd_tx[temp_rd_id].araddr = rd_wrap_boundry;
		
      rd_tx[temp_rd_id].read_byte_count= rd_tx[temp_rd_id].read_byte_count+1;
      if(rd_tx[temp_rd_id].read_byte_count == rd_tx[temp_rd_id].arlen+1)begin
	      v_s_intf.rlast<=1;
	      rd_tx.delete(temp_rd_id);
      end
     end//beats 
     end //aligned      
      end//arburst

      end
		 	   end 	//rst   
	end//forver 
endtask
       
endclass
