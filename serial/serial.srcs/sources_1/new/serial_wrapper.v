`default_nettype none

module serial_wrapper(
   input wire  clk, rst, trigger,
   output wire uart_tx, sending
);
   
   serial serial(.clk(clk), .rst(rst), .trigger(trigger), .uart_tx(uart_tx), .sending(sending));
     
endmodule
