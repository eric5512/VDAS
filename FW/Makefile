test-parallel: test_bench/tb_parallel.v parallel.v
	iverilog -g2005-sv -o tb test_bench/tb_parallel.v parallel.v
	vvp tb
	rm tb

test-queue: test_bench/tb_queue.v queue.v
	iverilog -g2005-sv -o tb test_bench/tb_queue.v queue.v
	vvp tb
	rm tb

test-AWG: test_bench/tb_AWG.v AWG.v
	iverilog -g2005-sv -o tb test_bench/tb_AWG.v AWG.v
	vvp tb
	rm tb

test-uart: test_bench/tb_uart.v uart_rx.v uart_tx.v
	iverilog -g2005-sv -o tb test_bench/tb_uart.v uart_rx.v uart_tx.v
	vvp tb
	rm tb

# test-onewire: test_bench/tb_onewire.v onewire.v
# 	iverilog -g2005-sv -o tb test_bench/tb_onewire.v onewire.v
# 	vvp tb
# 	rm tb

test: test-parallel test-queue test-AWG test-uart