module serial(
   input logic	clk, rst, trigger,
   output logic	uart_tx, sending
);

   logic [7:0] data;
   logic       busy, write = 0, sending = 0;
   
   logic [7:0] byte_buffer[14] = '{ "H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!", "\r", "\n" };
   logic [3:0]	    char_counter = 0;

   assign data = byte_buffer[char_counter];
   
   tx_uart tx_uart(.clk, .write, .data, .busy, .tx(uart_tx));

   always_ff @(posedge clk) begin
      if (rst) begin
	 sending <= 0;
	 char_counter <= 0;
      end
      else if (trigger && !sending) begin
	 sending <= 1;
	 write <= 1;
	 char_counter <= 0;
      end
      else if (sending && (char_counter < 14) && !busy)
	char_counter++;
      else if (sending && (char_counter == 14) && !busy) begin
	 write <= 0;
	 char_counter <= 0;
	 sending <= 0;
      end
   end
   
endmodule
