module serial(
   input logic	clk, rst, trigger,
   output logic	uart_tx, sending
);

   logic [7:0] data;
   logic       busy, write = 0;
   
   logic [7:0] byte_buffer[14] = '{ "H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!", "\r", "\n" };
   logic [3:0]	    char_counter = 0;

   enum { IDLE, SEND_FIRST_CLOCK, SEND_OTHER_CLOCKS } state = IDLE;
   
   assign data = byte_buffer[char_counter];
   
   tx_uart tx_uart(.clk, .write, .data, .busy, .tx(uart_tx));

   always_ff @(posedge clk) begin
      if (rst) begin
	 state <= IDLE;
	 write <= 0;
	 char_counter <= 0;
      end
      else
	case (state)
	  IDLE: if (trigger) begin
	     state <= SEND_FIRST_CLOCK;
	     write <= 1;
	     char_counter <= 0;
	  end
	  SEND_FIRST_CLOCK:
	    // First bit is special because the busy
	    // flag is not yet set, and we need to make
	    // sure counter is not erroneously incremented
	    state <= SEND_OTHER_CLOCKS;
	  SEND_OTHER_CLOCKS: if (!busy) begin
	     char_counter++;
	     if (char_counter == 14) begin
		state <= IDLE;
		write <= 0;
		char_counter <= 0;
	     end
	  end
	endcase
   end
   
endmodule
