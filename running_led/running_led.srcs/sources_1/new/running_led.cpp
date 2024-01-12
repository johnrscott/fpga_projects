#include <iostream>
#include "Vrunning_led.h"
#include <verilated.h>

int main(int argc , char **argv) {
    Verilated::commandArgs(argc, argv);
    Vrunning_led *tb = new Vrunning_led;

    for (int k = 0; k < 20; k++) {
	tb->clk = k&1;
	tb->eval();

	std::cout << "k = " << k
		  << " clk = " << (int)tb->clk
		  << " led[0] = " << (int)tb->leds << std::endl;
    }
}
