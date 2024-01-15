module serial(
   input logic	clk, rst, trigger,
   output logic	uart_tx, sending
);

   logic [7:0] data;
   logic       busy, write = 0;
   
   logic [7:0] byte_buffer[14] = '{ "H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!", "\r", "\n" };
   logic [3:0]	    char_counter = 0;

   enum { IDLE, LOAD_CHAR, TRANSMIT } state = IDLE;
   
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
	     char_counter <= 0;
	     data <= byte_buffer[char_counter];
	     write <= 1;
	     state <= LOAD_CHAR;
	  end
	  LOAD_CHAR: begin
	     state <= TRANSMIT;
	  end 
	  TRANSMIT: if (!busy) begin
	     write <= 0;
	     if (char_counter == 14) begin
		state <= IDLE;
		char_counter <= 0;
	     end
	     else begin
		state <= LOAD_CHAR;
		char_counter++;
	     end
	  end
	endcase
   end
   
endmodule
