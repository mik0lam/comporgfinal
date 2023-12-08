`include "chip.sv"
`include "decoder.sv"

`timescale 1ns / 1ps

module chip
  # ( parameter add_width = 13,
      parameter data_width = 16,
      parameter DATA_WIDTH_SHIFT = 1
    )
  
  (   input clk,
         input [add_width-1:0] addr,
         inout [data_width-1:0] data,
      input cs_input,
      input we,
      input oe
  );
  
  wire [1:0] cs;
  
  decoder #(.ENCODE_WIDTH(1)) dec
  (   .in(addr[add_width-1]),
      .out(cs) 
  );
  
  chip  #(.data_width(data_width/2)) u00
  (   .clk(clk),
   .addr(addr[add_width-2:0]),
   .data(data[(data_width>>DATA_WIDTH_SHIFT)-1:0]),
      .cs(cs[0]),
      .we(we),
      .oe(oe)
  );
  chip #(.data_width(data_width>>DATA_WIDTH_SHIFT)) u01
  (   .clk(clk),
   .addr(addr[addr_width-2:0]),
   .data(data[data_width-1:data_width>>DATA_WIDTH_SHIFT]),
      .cs(cs[0]),
      .we(we),
      .oe(oe)
  );

  chip  #(.data_width(data_width/2)) u10
  (   .clk(clk),
   .addr(addr[addr_width-2:0]),
   .data(data[(data_width>>DATA_WIDTH_SHIFT)-1:0]),
      .cs(cs[1]),
      .we(we),
      .oe(oe)
  );
  chip  #(.data_width(data_width>>DATA_WIDTH_SHIFT)) u11
  (   .clk(clk),
         .addr(addr[addr_width-2:0]),
         .data(data[data_width-1:data_width>>DATA_WIDTH_SHIFT]),
      .cs(cs[1]),
      .we(we),
      .oe(oe)
  );

endmodule