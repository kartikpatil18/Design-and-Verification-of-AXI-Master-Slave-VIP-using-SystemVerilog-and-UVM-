vlog run.svh \
+incdir+C:/uvm-1.2/src

vsim -novopt -suppress 12110 axi_top \
-sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi

#add wave -r sim:axi_top/p_intrf/*

run -all


