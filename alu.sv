`timescale 1ns / 1ps

module alu(
    input [15:0] A, B,  // ALU 16-bit Inputs
  input [1:0] ALU_Sel, // ALU Selection (4-bit for opcodes)
    output [15:0] ALU_Out // ALU 16-bit Output
);
    reg [15:0] ALU_Result;
    assign ALU_Out = ALU_Result; // ALU out

    always @(*)
    begin
        case(ALU_Sel)
            2'b00: // And
                ALU_Result = A && B;
            2'b01: // Addition
                ALU_Result = A + B;
        
            2'b10: // Subtraction
                ALU_Result = A - B; 
            2'b11 // OR
                ALU_Result = A || B; // Default to accumulator
        endcase
    end
endmodule
