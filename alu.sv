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
            4'b00: // Clear
                ALU_Result = 0;
            4'b01: // Addition
                ALU_Result = A + B;
            4'b10: // Subtraction
                ALU_Result = A - B; 
            default:
                ALU_Result = A; // Default to accumulator
        endcase
    end
endmodule