IFLAGS=-Iobj_dir/ -I/usr/share/verilator/include/
VERILATED_SRC=/usr/share/verilator/include/verilated.cpp

running_led.bin: running_led.cpp
	g++ $^ obj_dir/Vrunning_led__ALL.a $(VERILATED_SRC) $(IFLAGS) -o $@
