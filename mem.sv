`include "chip.sv"
`include "decoder.sv"
`include "L1Cache.sv"

`timescale 1ns / 1ps

module mem
  # (
    parameter add_width = 13,
    parameter data_width = 16,
    parameter DATA_WIDTH_SHIFT = 1
  )
  (
    input clk,
    input rst, // Adding a reset input
    input [add_width-1:0] addr,
    inout [data_width-1:0] data,
    input cs_input,
    input we,
    input oe
  );

  wire [1:0] cs;
  wire [data_width-1:0] l1_cache_data;

  decoder #(.ENCODE_WIDTH(1)) dec
  (
    .in(addr[add_width-1]),
    .out(cs)
  );

  L1Cache #(
    .DATA_WIDTH(data_width),
    .CACHE_SIZE_BITS(75000),
    .INDEX_WIDTH(7),  // You may adjust this based on your cache size
    .OFFSET_WIDTH(3), // Assuming 8 bits per byte
    .TAG_WIDTH(6)     // You may adjust this based on your cache size
    // Add other parameters as needed
  ) l1_cache
  (
    .clk(clk),
    .rst(rst),
    .address(addr),
    .write_data(data),
    .write_enable(we),
    .read_enable(oe),
    .read_data(l1_cache_data)
  );

  chip #(.data_width(data_width/2)) u00
  (
    .clk(clk),
    .addr(addr[add_width-2:0]),
    .data(l1_cache_data[(data_width>>DATA_WIDTH_SHIFT)-1:0]),
    .cs(cs[0]),
    .we(we),
    .oe(oe)
  );

  chip #(.data_width(data_width>>DATA_WIDTH_SHIFT)) u01
  (
    .clk(clk),
    .addr(addr[add_width-2:0]),
    .data(l1_cache_data[data_width-1:data_width>>DATA_WIDTH_SHIFT]),
    .cs(cs[0]),
    .we(we),
    .oe(oe)
  );

  chip #(.data_width(data_width/2)) u10
  (
    .clk(clk),
    .addr(addr[add_width-2:0]),
    .data(l1_cache_data[(data_width>>DATA_WIDTH_SHIFT)-1:0]),
    .cs(cs[1]),
    .we(we),
    .oe(oe)
  );

  chip #(.data_width(data_width>>DATA_WIDTH_SHIFT)) u11
  (
    .clk(clk),
    .addr(addr[add_width-2:0]),
    .data(l1_cache_data[data_width-1:data_width>>DATA_WIDTH_SHIFT]),
    .cs(cs[1]),
    .we(we),
    .oe(oe)
  );

endmodule
