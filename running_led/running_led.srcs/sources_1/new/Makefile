IFLAGS=-Iobj_dir/ -I/usr/share/verilator/include/
VERILATED_SRC=/usr/share/verilator/include/verilated.cpp

running_led.bin: running_led.cpp obj_dir/Vrunning_led__ALL.a
	g++ $^ $(VERILATED_SRC) $(IFLAGS) -o $@

obj_dir/Vrunning_led__ALL.a: obj_dir
	make -C obj_dir -f Vrunning_led.mk

obj_dir: running_led.v
	verilator -Wall -cc running_led.v

.PHONY: clean
clean:
	rm -rf obj_dir *.bin

