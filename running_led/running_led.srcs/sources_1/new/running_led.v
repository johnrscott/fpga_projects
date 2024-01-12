`default_nettype none

/// Wishbone interface
module running_led(
   input wire	    clk_i, rst_i, cyc_i, stb_i, we_i,
   input wire [1:0] adr_i,
   input wire [3:0] dat_i,
   output wire	    stall_o, ack_o,
   output reg [3:0] dat_o
);

   wire busy;

   // Immediately acknowledge any transaction, apart from
   // when stalled.
   initial ack_o = 1'b0;
   always @(posedge clk_i)
     ack_o <= stb_i && !stall_0;

   // Stall on writes if busy
   assign stall_o = busy && we_i;

   // Always return read data
   assign dat_o = state;
   
   // For the formal verification, the cover checks will fail
   // if the clock rate is too high, because too many steps are
   // needed before anything happens. For running on a board,
   // change back to 100 MHz.
   //parameter	    CLK_RATE_HZ = 100_000_000;
   parameter	    CLK_RATE_HZ = 5;

   // Current state of the running LED
   reg [2:0]	    state = 0;
   
   // Define the tick signal that triggers a change of state
   reg [31:0]	    wait_counter = CLK_RATE_HZ - 1;

   always @(posedge clk_i) begin
      if (rst_i)
	wait_counter <= CLK_RATE_HZ - 1;
      else
	// If the state is not idle, then run the
	// wait counter
	if (state != 0)
	  if (wait_counter == 0)
	    wait_counter <= CLK_RATE_HZ - 1;
	  else
	    wait_counter <= wait_counter - 1'b1;
   end

   // Update state
   always @(posedge clk_i) begin
      if (rst)
	state <= 0; // Reset to idle
      else if (request && !busy)
	state <= 1; // Initiate request
      else if ((state >= 7) && (wait_counter == 0))
	state <= 0;
      else
	if (wait_counter == 0)
	  state <= state + 1;
   end

   assign busy = (state != 0);
   
   // Now determine the lit LED from the state
   always @(*) begin
      case (state)
	3'h1: leds = 4'b0001;
	3'h2: leds = 4'b0010;
	3'h3: leds = 4'b0100;
	3'h4: leds = 4'b1000;
	3'h5: leds = 4'b0100;
	3'h6: leds = 4'b0010;
	3'h7: leds = 4'b0001;
	default: leds = 0;
      endcase
   end
   
`ifdef FORMAL

   // always @(posedge clk_i)
   //   if (past_valid && $past(rst))
   //     reset_works: assert((wait_counter == (CLK_RATE_HZ - 1)) && (state == 0));
   
   property p_only_one_led;
      @(posedge clk_i) $onehot0(leds);
   endproperty
   
   // Check that the only valid outputs are exactly one LED
   // lit at a time
   only_one_led: assert property(p_only_one_led);
   
   property p_state_valid;
      @(posedge clk_i) state < 8;
   endproperty
   
   // For a check like this, notice how it fails if you remote
   // the initialisation line state = 0. This is because state
   // could begin with any value in theory, so it could violate
   // this check right at the start.
   no_invalid_states: assert property(p_state_valid);

   property p_wait_counter_in_range;
      @(posedge clk_i) wait_counter < CLK_RATE_HZ;
   endproperty
   
   // Check the counter is always in range
   wait_counter_value: assert property(p_wait_counter_in_range);

   property p_led_n_on(int n);
      @(posedge clk_i) leds[n] == 1;
   endproperty
   
   // Check that each LED lights at least once
   
   led_0_on: cover property(p_led_n_on(0));
   led_1_on: cover property(p_led_n_on(1));
   led_2_on: cover property(p_led_n_on(2));
   led_3_on: cover property(p_led_n_on(3));

   property p_busy_when_leds_on;
      @(posedge clk_i) leds != 0 |-> busy;
   endproperty
   
   // Check busy signal is always asserted when LEDs are on
   busy_asserted: assert property(p_busy_when_leds_on);

   sequence changing_state;
      busy && (wait_counter == 0) && !rst;
   endsequence
   
   // Check that the state increments while busy
   property p_state_increments_while_busy;
      @(posedge clk_i) changing_state |=> (state == (3'b111 & ($past(state)+1)));
   endproperty

   state_increments_while_busy: assert property(p_state_increments_while_busy);
   
   // always @(posedge clk_i)
   //   if (past_valid && $past(busy) && ($past(wait_counter) == 0) && !$past(rst))
   //     state_increment_by_one: assert (state == $past(state) + 1);

   
`endif
		    
endmodule
