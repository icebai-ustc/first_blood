quit -sim;
cd       C:/Users/lenovo/Desktop/SPI/sim
vlib    work
vmap    work    work
#vlog    -novopt -incr  -work work  "configf_tb.v"
#vlog    -novopt -incr  -work work  "configf_entity.v"
#vlog    -novopt -incr  -work work  "configf_host.v"
#vlog    -novopt -incr  -work work  "configf_wrap.v"
#vlog    -novopt -incr  -work work  "errb_ram4K8B.v"
vlog +libext+.v -y . test.v

vlog -novopt -incr -work work "D:/setupprogram/ISE/14.2/ISE_DS/ISE/verilog/src/glbl.v"
vsim    -novopt -t  1ps  -L xilinxcorelib_ver -L unisims_ver  work.test work.glbl
log     -r  /*
radix   -hex
configure   wave    -signalnamewidth    1

#mem load -i bram_ini.mem -format binary -filltype value -filldata 1 -fillradix hexadecimal -skip 0 /configf_tb/configf_wrap_inst/ram_inst/inst/native_mem_module/blk_mem_gen_v7_2_inst/memory
#add wave -position insertpoint  \
#sim:/configf_tb/clk \
#sim:/configf_tb/entity_clk \
#sim:/configf_tb/entity_cs_n \
#sim:/configf_tb/entity_di \
#sim:/configf_tb/entity_do \
#sim:/configf_tb/entity_hold_n \
#sim:/configf_tb/entity_wpn \
#sim:/configf_tb/reset_n
#add wave -position insertpoint  \
#sim:/configf_tb/configf_wrap_inst/configf_entity_inst/current_state
#add wave -position insertpoint  \
#sim:/configf_tb/configf_wrap_inst/configf_entity_inst/entity_cs_n
#add wave -position insertpoint  \
#sim:/configf_tb/configf_wrap_inst/configf_entity_inst/entity_cmd_en_in
