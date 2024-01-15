module tx_uart_tb;
   
   timeunit 1ns;
   timeprecision 10ps;
   
   logic clk = 0, rst, write, busy, tx;
   logic [7:0] data;
      
   always begin
      #5 clk = ~clk;
   end
      
   tx_uart tx_uart(.clk, .rst, .write, .data, .busy, .tx);

   default clocking cb @(posedge clk);
      default input #1 output #2;
      output rst, write, data;
      input  busy, tx;
   endclocking
   
   initial begin
   
      cb.rst <= 0;
      cb.data <= "o";

      ##3 cb.write <= 1;
      //##1 cb.write <= 0;
      
   end
     
endmodule
