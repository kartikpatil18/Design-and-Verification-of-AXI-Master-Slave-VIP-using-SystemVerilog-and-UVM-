module axi_top;
//we need to genrate clk and reset signal then link to interface 
bit aclk, aresetn;

initial begin 
	aclk=0; 
	forever #5 aclk=~aclk; //100Mhz 
end

initial begin //in active using ative low reset 0 - not working state  1 - working state 
	aresetn=0;//initualizing all outputs inside ip 
	repeat(2)@(posedge aclk);
	aresetn=1;
end

axi_interface p_intf(aclk,aresetn);



//point physical iterface to virtual interface 
initial begin 
	uvm_config_db#(virtual axi_interface)::set(null,"*","v_intf",p_intf);//virtual axi_interface v_intf 
	//v_intf=p_intf;
end

//include top_test class
initial begin 
	run_test("wrap_100_wr_rd__test");
end
endmodule 
