VERILATOR_INC=/usr/share/verilator/include/
IFLAGS=-Iobj_dir/ -I$(VERILATOR_INC)

tx_uart.bin: serial.cpp obj_dir/Vtx_uart__ALL.a
	g++ -O2 $^ $(VERILATOR_INC)/verilated.cpp $(VERILATOR_INC)/verilated_vcd_c.cpp $(IFLAGS) -o $@

obj_dir/Vtx_uart__ALL.a: tx_uart.sv
	verilator -Wall -cc --trace tx_uart.sv
	make -C obj_dir -f Vtx_uart.mk

.PHONY: clean
clean:
	rm -rf obj_dir *.bin
