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

test-deltasigma: test_bench/tb_deltasigma.v deltasigma.v
	iverilog -g2005-sv -o tb test_bench/tb_deltasigma.v deltasigma.v
	vvp tb
	rm tb

test-divider: test_bench/tb_divider.v divider.v
	iverilog -g2005-sv -o tb test_bench/tb_divider.v divider.v
	vvp tb
	rm tb

test-control: test_bench/tb_control.v control.v
	iverilog -g2005-sv -o tb test_bench/tb_control.v control.v
	vvp tb
	rm tb


test: test-parallel test-queue test-AWG test-uart test-deltasigma test-control