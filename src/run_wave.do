transcript on

vlib work
vlog -writetoplevels questa.tops -timescale 1ns/1ns design/top.sv testbench/testbench.sv
echo "" > test_results.txt
vsim -f questa.tops -batch -do "
 vsim -voptargs=+acc=npr;
 add wave -noupdate -height 30 /tb/uut/clk;
 add wave -noupdate -height 30 /tb/uut/rst;
 add wave -noupdate -height 30 /tb/uut/r_addr;
 add wave -noupdate -height 30 /tb/uut/r_avalid;
 add wave -noupdate -height 30 /tb/uut/r_aready;
 add wave -noupdate -height 30 /tb/uut/r_dvalid;
 add wave -noupdate -height 30 /tb/uut/r_data;
 add wave -noupdate -height 30 /tb/uut/w_valid;
 add wave -noupdate -height 30 /tb/uut/w_data;
 add wave -noupdate -height 30 /tb/uut/w_ready;
 add wave -noupdate -height 30 /tb/uut/r_decoder_valid;
 add wave -noupdate -height 30 /tb/uut/w_decoder_valid;
 update;
 run -all;
" -voptargs=+acc=npr +test_id=0
cat test_results.txt