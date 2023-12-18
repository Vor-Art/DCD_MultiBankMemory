transcript on

vlib work
vlog -writetoplevels questa.tops -timescale 1ns/1ns design/top.sv testbench/testbench.sv
echo "" > test_results.txt
vsim -f questa.tops -batch -do "vsim -voptargs=+acc=npr ; run -all; exit" -voptargs=+acc=npr +test_id=1
cat test_results.txt