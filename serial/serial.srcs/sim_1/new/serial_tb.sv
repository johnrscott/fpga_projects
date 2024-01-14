module serial_tb;
   
   timeunit 1ns;
   timeprecision 10ps;
   
   logic clk = 0, rst, trigger, uart_tx, sending;
   
   always begin
      #5 clk = ~clk;
   end
      
   serial serial(.clk, .rst, .trigger, .uart_tx, .sending);

   default clocking cb @(posedge clk);
      default input #1step output #4;
      output trigger, rst;
      input  uart_tx, sending;
   endclocking
   
   initial begin
   
      cb.trigger <= 0;
      cb.rst <= 0;

      ##3 cb.trigger <= 1;
      //##1 cb.trigger <= 0;
      
      
   end
     
endmodule
