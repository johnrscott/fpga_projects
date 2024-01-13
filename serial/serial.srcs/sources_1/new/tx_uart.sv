module tx_uart(
   input logic	     clk, write,
   input logic [7:0] data,
   output logic	     busy, tx
);

   // Includes start and stop bit
   logic [9:0] tx_data
   
   enum [4:0] { IDLE, START_BIT, DATA_BIT_[8], STOP_BIT } state;

   initial { busy, state } = { 1'b0, IDLE };

   
   
   always_ff @(posedge clk) begin
      if ((state == IDLE) && write) begin
	 // Load new data to transmit
	 tx_data[8:1] <= data;
	 // Start a new transmission
	 state <= START_BIT;
      end
	 
   end

   // 

   
endmodule
