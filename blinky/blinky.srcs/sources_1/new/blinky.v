`default_nettype none

module blinky (
   input wire clk, rst,
   output wire led
);

   parameter CLOCK_RATE_HZ = 100_000_000;
   parameter INCREMENT = (1<<30)/(CLOCK_RATE_HZ/4);
   
   reg [31:0] counter;

   always @(posedge clk) begin
      if (rst)
	counter = 0;
      else
	counter <= counter + INCREMENT;
   end

   assign led = counter[31];
   
endmodule
