`default_nettype none

module running_led(
  input wire clk,
  input wire rst,
  output reg [3:0] leds
  );

   parameter	    CLK_RATE_HZ = 100_000_000;

   // Current state of the running LED
   reg [2:0]	    state = 0;
   
   // Define the tick signal that triggers a change of state
   reg [31:0]	    wait_counter = CLK_RATE_HZ - 1;

   always @(posedge clk) begin
      if (rst || (wait_counter == 0))
	wait_counter <= CLK_RATE_HZ - 1;
      else
	wait_counter <= wait_counter - 1'b1;
   end

   // Update state
   always @(posedge clk) begin
      if (rst)
	state <= 0;
      else if (wait_counter == 0)
	if (state < 5)
	  // LED goes up then back down
	  state <= state + 1;
	else
	  // Final LED in pattern; reset
	  state <= 0;

   end
   
   // Now determine the lit LED from the state
   always @(*) begin
      case (state)
	3'h0: leds = 4'b0001;
	3'h1: leds = 4'b0010;
	3'h2: leds = 4'b0100;
	3'h3: leds = 4'b1000;
	3'h4: leds = 4'b0100;
	3'h5: leds = 4'b0010;
	default: leds = 0;
      endcase
   end
   
`ifdef FORMAL

   // For a check like this, notice how it fails if you remote
   // the initialisation line state = 0. This is because state
   // could begin with any value in theory, so it could violate
   // this check right at the start.
   always @(posedge clk)
     no_invalid_states: assert(state <= 5);

   // Check that the only valid outputs are exactly one LED
   // lit at a time
   always @(posedge clk)
     exactly_one_led: assert($onehot(leds));
   
`endif
		    
endmodule
