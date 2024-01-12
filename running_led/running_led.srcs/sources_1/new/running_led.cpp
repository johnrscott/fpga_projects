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

    
	/// Advance the clock by a single tick
	///
	/// Calling this function does three things:
	///
	/// 1. Evaluates the model based on inputs that
	/// have been set since last calling tick(). These
	/// are assumed to be driven from the same clocking
	/// domain as this clock, so they should change just
	/// after the last rising edge of the clock. The
	/// delay is the hold time. Write to the trace file.
	///
	/// 2. After half a clock period, set the falling
	/// edge of the clock and write to the trace file.
	///
	/// 3. After another half clock period, set the rising
	/// edge of the clock, and evaluate. Write the results
	/// to the trace file. Since both the rising clock edge
	/// and all dependent logic are evaluated at the same
	/// time (and written to the trace file under the same
	/// timestamp), this models the logic as having zero
	/// propagation delay.
	///
	void tick() {

	    // Assume the user set inputs outside. Evaluate
	    // the model based on these inputs, and write the
	    // results to the trace file a hold time after the
	    // previous rising clock edge (at the end of this
	    // tick function).
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(10*tick_ + hold_);
	    }	    

	    // Now set clock falling edge + eval + write
	    // falling edge to trace
	    tb_->clk_i = 0;
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(10*tick_ + 5);
	    }	    

	    // Rising edge + eval. All signals depending on
	    // posedge update. Write all signals to trace at
	    // same time (acts like logic has zero propagation
	    // delay).
	    tb_->clk_i = 1;
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(10*tick_ + 10);
		tfp_->flush();
	    }

	    tick_++;
	}
    private:
	Vrunning_led *tb_;
	VerilatedVcdC *tfp_;
	unsigned tick_{0};
	unsigned hold_{1};
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
    
    // Keep transaction-initiating signals
    // asserting while any stall is ongoing
    while (tb->stall_o) {
	clk.tick();
    }

    // When stall is over, keep the stb_i
    // etc. asserted for one cycle (starts
    // the new transaction)
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

void wishbone_write(
    util::clock &clk,
    Vrunning_led *tb,
    unsigned address,
    unsigned write_data) {

    // Start the wishbone transaction
    tb->cyc_i = 1;
    tb->we_i = 1;
    tb->stb_i = 1;
    tb->adr_i = address;
    tb->dat_i = write_data;
    
    // Keep transaction-initiating signals
    // asserting while any stall is ongoing
    while (tb->stall_o) {
	clk.tick();
    }

    // When stall is over, keep the stb_i
    // etc. asserted for one cycle (starts
    // the new transaction)
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

    // Perform a read
    wishbone_read(clk, tb, 0);

    // Perform two writes
    for (int cycle = 0; cycle < 2; cycle++) {

	// Delay 5 cycles
	for (int k = 0; k < 5; k++) {
	    clk.tick();
	}

	wishbone_write(clk, tb, 0, 0);
	
    }    

}
