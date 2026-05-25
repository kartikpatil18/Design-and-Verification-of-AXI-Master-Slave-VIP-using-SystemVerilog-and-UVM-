interface axi_interface(input bit aclk, aresetn);//clocking blocks and modports needed
	
	//5 channels 
	//write address channel 10 signals 
	logic awvalid;
	logic awready;
	logic [31:0] awaddr;
	logic [15:0] awid;
	logic [1:0] awburst;
	logic [1:0] awlock;
	logic [2:0] awsize;
	logic [2:0] awprot;
	logic [3:0] awlen;
	logic [3:0] awcache;
	
	//write data channel 
	logic [63:0] wdata;//maximum suppoprts 1024 bits of data 
	logic [7:0] wstrb;// wdata data 8bytes are presnt so wstrb 8bit needed
    logic wlast;
    logic [15:0] wid;
    logic wvalid;
    logic wready;
    
	//write response channel 
	logic bvalid;
    logic bready;
    logic [15:0] bid;
	logic[1:0] bresp;//ok.ex_ok, slave error , decode error
	
    //read address channel 10 signals 
	logic arvalid;
	logic arready;
	logic [31:0] araddr;
	logic [15:0] arid;
	logic [1:0] arburst;
	logic [1:0] arlock;
	logic [2:0] arsize;
	logic [2:0] arprot;
	logic [3:0] arlen;
	logic [3:0] arcache;
	
	//read data channe;
	logic rvalid;
	logic rready;
	logic [15:0] rid;
	logic rlast;
	logic [1:0] rresp;//every beats will get response 
	logic [63:0] rdata;
	
endinterface 
