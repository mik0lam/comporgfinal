`timescale 1ns / 1ps

module test_chip;
  parameter add_width = 12;
  parameter data_width = 8;
  
  reg clk;
  reg cs;
  reg we;
  reg oe;
  reg [add_width - 1:0] addr;
  wire [data_width - 1:0] data;
  reg [data_width - 1:0] testbench_data;
  
  chip #(.data_width(data_width)) u0
  (
    .clk(clk),
    .cs(cs),
    .we(we),
    .oe(oe),
    .addr(addr),
    .data(data)
  );
  
  always #20 clk = ~clk;
  assign data = !oe ? testbench_data : 'hz;

  integer i;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    {clk, cs, we, addr, testbench_data, oe} <= 0;

    repeat (2) @ (posedge clk);

    for (i = 0; i < 16; i = i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 1; cs <= 1; oe <= 0; testbench_data <= $random;
    end

    for (i = 0; i < 16; i= i+1) begin
      repeat (1) @(posedge clk) addr <= i; we <= 0; cs <= 1; oe <= 1;
    end

    @(posedge clk) cs <= 0;

    #360 $finish;
  end
endmodule

  