#include <iostream>
#include "Vrunning_led.h"
#include <verilated.h>
#include <verilated_vcd_c.h>

namespace util {

    class clock {
    public:

	/// Make a new clock object associated
	/// to a top model and optionally a trace
	/// object.
	clock(Vrunning_led *tb,
	      VerilatedVcdC *tfp)
	    : tb_{tb}, tfp_{tfp} {}

    
	/// Advance the clock by a single clock
	/// cycle
	void tick() {    
	    tb_->clk_i = 0;
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(tick_++);
	    }
    
	    tb_->clk_i = 1;
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(tick_++);
		tfp_->flush();
	    }
	}
    private:
	Vrunning_led *tb_;
	VerilatedVcdC *tfp_;
	unsigned tick_;
    };
}


unsigned wishbone_read(
    util::clock &clk,
    Vrunning_led *tb,
    unsigned address) {
    
    // Start the wishbone transaction
    tb->cyc_i = 1;
    tb->we_i = 0;
    tb->stb_i = 1;
    tb->adr_i = address;
    
    // Keep transaction initiating signals
    // asserting while any stall is ongoing
    while (tb->stall_o) {
	clk.tick();
    }

    // When stall is over, keep the stb_i
    // etc. asserted for one cycle (starts
    // the new transaction
    clk.tick();

    // Deassert the strobe
    tb->stb_i = 0;

    // Wait for the acknowledgement
    while (!tb->ack_o) {
	clk.tick();
    }

    // Deassert cycle signal and read
    // response data
    tb->cyc_i = 0;    
    return tb->dat_o;
}

int main(int argc , char **argv) {
    Verilated::commandArgs(argc, argv);
    Vrunning_led *tb{new Vrunning_led{}};

    // Trace output
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp{new VerilatedVcdC{}};
    tb->trace(tfp, 99);
    tfp->open("running_led_trace.vcd");

    util::clock clk{tb, tfp};

    wishbone_read(clk, tb, 0);
    
    // Delay 5 cycles
    for (int k = 0; k < 5; k++) {
	clk.tick();
    }

}
