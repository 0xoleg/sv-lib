.PHONY: run

run:
	vlib ./
	vmap my_lib ./
	vlog -sv testbench.sv ./uart_tx/uart_tx.sv ./uart_rx/uart_rx.sv -work my_lib
	vsim -voptargs="+acc" -L work my_lib.testbench
