
typedef enum{WRITE_ONLY, READ_ONLY, WRITE_THEN_READ, WRITE_PARALLEL_READ} wr_rd;
class axi_tx extends uvm_sequence_item;
	`uvm_object_utils(axi_tx);
	 function new(string name="");
		 super.new(name);
	 endfunction 
	 int byte_count;
	 int read_byte_count;
        rand wr_rd w_r;
        rand logic awvalid;
	 logic awready;
	rand logic [31:0] awaddr;//4
	rand logic [15:0] awid;
	rand logic [1:0] awburst;
	rand logic [1:0] awlock;
	rand logic [2:0] awsize;
	rand logic [2:0] awprot;
	rand logic [3:0] awlen;//7   //8 beats of random data we need 
	rand logic [3:0] awcache;
	//write data channel 
	//8,16,32,64,128,256,512,1024
	rand logic [63:0] wdata [$];//maximum suppoprts 1024 bits of data wdata[0]  wdata[1] wdata[2]  --- wdata[7]
	rand logic [7:0] wstrb;// wdata data 8bytes are presnt so wstrb 8bit needed
        rand logic wlast;
        rand logic [15:0] wid;
        rand logic wvalid;
        logic wready;
        //write response channel 
        logic bvalid;
        rand logic bready;
        logic [15:0] bid;
        logic[1:0] bresp;//ok.ex_ok, slave error , decode error   each transaction (number of beats) will get 1 response
        //read address channel 10 signals 
	rand logic arvalid;
	logic arready;
	rand logic [31:0] araddr;
	rand logic [15:0] arid;
	rand logic [1:0] arburst;
	rand logic [1:0] arlock;
	rand logic [2:0] arsize;
	rand logic [2:0] arprot;
	rand logic [3:0] arlen;
	rand logic [3:0] arcache;	
	//read data channe;
	logic rvalid;
	rand logic rready;
	logic [15:0] rid;
	logic rlast;
	logic [1:0] rresp;//every beats will get response 
	logic [63:0] rdata;



	//randomization time always  genric 
	constraint c1{
		    wdata.size()==awlen+1;//wdata size is 8 
		    }

                  
//master need to send multiple transfers of random data uin each transaction 
//number of transfers desided by sug awlen 
//awlen=3
//
//wdata.size() = 4  - wdata[0]=64'h1122334455667788 wdata[1]=64'haabbccdd1a1b1c1d  wdata[2]  wdata[3] 
//
//for(int i=0; i<=awlen; i++)begin 
//  vif.wdata= tx.wdata.pop_back();
//  @(posedge clk);
//  end 
//
 endclass
