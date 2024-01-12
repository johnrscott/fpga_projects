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
	/// Calling this function triggers a rising edge of the clock,
	/// followed by a falling edge (one period in total).
	///
	/// It is expected that some signals have been set
	/// (combinationally) before calling this function. As a
	/// result, this function evals the state of the simulator
	/// before changing the clock state. In addition, this
	/// evaluated state is stored in the trace, at the _previous_
	/// rising edge.
	///
	/// NOTE: a better order for the simulation would be:
	/// 1. posedge clock
	/// 2. update outputs based on new clock edge
	/// 3. change inputs to drive design
	/// 4. negedge clock
	///
	/// This would allow a more realistic wave trace, where all
	/// signals (inputs and outputs) change shortly after the
	/// rising edge. This could be achieved with one tick():
	///
	/// Outside:
	/// Change inputs
	/// 
	/// tick() function:
	/// 0. Call eval and write trace at 10*t + hold
	/// where hold = 1 say (models inputs coming from the same
	/// clocking domain, with a small propagation delay).
	/// 1. Negedge, call eval and write trace at 10*t + 5
	/// 2. Posedge, call eval and write trace at 10*t + 10 (models logic
	/// as having 0 propagation delay for outputs)
	///
	///
	void tick() {

	    // Evaluate changes due to design inputs, that have been
	    // modified since last calling tick. These changes should
	    // occur at least a setup time before the rising clock
	    // edge. To model the way hardware works in a design where
	    // the inputs come from combinational logic driven by a
	    // clock in the same clock domain, these signals would
	    // ideally change very soon after the previous rising edge.
	    // However, that is not possible in verilator trace,
	    // because it is not possible to write trace signals at
	    // a time before the falling edge (written last tick).
	    //
	    tb_->eval();
	    if (tfp_) {
		tfp_->dump(10*tick_ - setup_);
	    }	    

	    // Now set clock rising edge
	    tb_->clk_i = 1;

	    // Calling evaluate here will re-evaluate the model based
	    // on the new clock value, including all combinational
	    // logic depending on the clock value rising. This
	    // models propagation delays as zero time.
	    tb_->eval();

	    // Store the state of the rising clock edge and all
	    // combinational logic changes that happen as a result.
	    if (tfp_) {
		tfp_->dump(10*tick_);
	    }	    

	    // Falling edge of clock. Evaluate logic
	    // based on falling edge (nothing will
	    // change), and save result
	    tb_->clk_i = 0;
	    tb_->eval();

	    // Store the falling edge of the clock (nothing else
	    // should change, logic is posedge only).
	    if (tfp_) {
		tfp_->dump(10*tick_ + 5);
		tfp_->flush();
	    }

	    tick_++;
	}
    private:
	Vrunning_led *tb_;
	VerilatedVcdC *tfp_;
	unsigned tick_{1};
	unsigned setup_{4};
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
