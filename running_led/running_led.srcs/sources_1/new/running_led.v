`default_nettype none

module running_led(
  input wire clk,
  input wire rst,
  output reg [3:0] leds
  );

   parameter	    CLK_RATE_HZ = 100_000_000;

   // Current state of the running LED
   reg [2:0]	    state;
   
   // Define the tick signal that triggers a change of state
   reg [31:0]	    wait_counter;

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
   
		    
endmodule
