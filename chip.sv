`timescale 1ns / 1ps

module chip
# (
  parameter add_width = 12,
  parameter data_width = 8,
  parameter add_length = (1<<14)
)
(
  input clk,
  input [add_width - 1:0] addr,
  input [data_width - 1:0] data,
  input cs, 
  input we,
  input oe
);
  
  reg [data_width - 1: 0] memory[add_length];
  reg [data_width - 1: 0] temp_data;
  
  always @(posedge clk) begin
    if(cs & we)
      memory[addr] <= data;
  end
  
  always @(negedge clk) begin
    if(cs & !we)
      temp_data <= memory[addr];
  end 
  
  assign data = cs & oe & !we ? temp_data : 'hz;
  
endmodule