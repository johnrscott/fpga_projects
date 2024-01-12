#include <iostream>
#include "Vrunning_led.h"
#include <verilated.h>
#include <verilated_vcd_c.h>

int clock_cycle(int tick,
	  Vrunning_led *tb,
	  VerilatedVcdC *tfp) {    
    tb->clk_i = 0;
    tb->eval();
    if (tfp) {
	tfp->dump(tick++);
    }
    
    tb->clk_i = 1;
    tb->eval();
    if (tfp) {
	tfp->dump(tick++);
	tfp->flush();
    }
    return tick;
}

int main(int argc , char **argv) {
    Verilated::commandArgs(argc, argv);
    Vrunning_led *tb{new Vrunning_led{}};

    // Trace output
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp{new VerilatedVcdC{}};
    tb->trace(tfp, 99);
    tfp->open("running_led_trace.vcd");

    int tick{0};
    for (int k = 0; k < 20; k++) {
	tick = clock_cycle(tick, tb, tfp);
    }
}
