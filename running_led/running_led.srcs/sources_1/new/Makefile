VERILATOR_INC=/usr/share/verilator/include/
IFLAGS=-Iobj_dir/ -I$(VERILATOR_INC)

running_led.bin: running_led.cpp obj_dir/Vrunning_led__ALL.a
	g++ -O2 $^ $(VERILATOR_INC)/verilated.cpp $(VERILATOR_INC)/verilated_vcd_c.cpp $(IFLAGS) -o $@

obj_dir/Vrunning_led__ALL.a: running_led.v
	verilator -Wall -cc --trace running_led.v
	make -C obj_dir -f Vrunning_led.mk

.PHONY: clean
clean:
	rm -rf obj_dir *.bin

