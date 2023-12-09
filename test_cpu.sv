`timescale 1ns / 1ps

module cpu;
  parameter add_width = 13; // remaining 12 bits of instruction
  parameter data_width = 16; // 16Ki * 8
  
  reg osc;
  localparam period = 100; // calculate clock period latency
  wire clk;
  assign clk = osc;
  
  reg cs; // chip select
  reg we; // write enable
  reg oe; // output enable
  integer i;
  
  reg [add_width - 1 : 0] MAR;
  wire [data_width - 1 : 0] data;
  reg [data_width - 1 : 0] testbench_data;
  assign data = !oe ? testbench_data : 'hz;
  
  // sync the ram_large
  mem  #(.data_width(data_width)) chip
  (   .clk(clk),
   	  .addr(MAR),
   	  .data(data[data_width-1:0]),
      .cs_input(cs),
      .we(we),
      .oe(oe)
  );
  
  reg [15:0] A;
  reg [15:0] B;
  reg [15:0] ALU_Out;
  reg [1:0] ALU_Sel;
  
  alu alu16(
    .A(A),
    .B(B), // ALU 16-bit inputs
    .ALU_Sel(ALU_Sel),
    .ALU_Out(ALU_Out)
  );
  
  reg [15:0] PC = 'h100; // program counter
  reg [15:0] IR = 'h0; // instruction register
  reg [15:0] MBR = 'h0; // memory buffer register
  reg [15:0] AC = 'h0; // accumulator
  
  initial osc = 1;
  always begin
    #period osc = ~osc;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    // write program into memory
    @(posedge clk) MAR <= 'h100 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0128;
    @(posedge clk) MAR <= 'h102 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h212A;
    @(posedge clk) MAR <= 'h104 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h1128;
    @(posedge clk) MAR <= 'h106 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h1130;
    @(posedge clk) MAR <= 'h108 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h012C;
    @(posedge clk) MAR <= 'h10A ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h312E;
    @(posedge clk) MAR <= 'h10C ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h112C;
    @(posedge clk) MAR <= 'h10E ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hE000;
    @(posedge clk) MAR <= 'h110 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h4114;
    @(posedge clk) MAR <= 'h112 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hF000;
    @(posedge clk) MAR <= 'h114 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h012A;
    @(posedge clk) MAR <= 'h116 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h2128;
    @(posedge clk) MAR <= 'h118 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h112A;
    @(posedge clk) MAR <= 'h11A ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h1130;
    @(posedge clk) MAR <= 'h11C ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h012C;
    @(posedge clk) MAR <= 'h11E ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h312E;
    @(posedge clk) MAR <= 'h120 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h112C;
    @(posedge clk) MAR <= 'h122 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hE000;
    @(posedge clk) MAR <= 'h124 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h4100;
    @(posedge clk) MAR <= 'h126 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hF000;
    @(posedge clk) MAR <= 'h128 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0000;
    @(posedge clk) MAR <= 'h12A ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0001;
    @(posedge clk) MAR <= 'h12C ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h000B;
    @(posedge clk) MAR <= 'h12E ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'h0001;
    @(posedge clk) MAR <= 'h130 ; we <= 1; cs <= 1; oe <= 0; testbench_data <= 'hFFFF;
    @(posedge clk) PC <= 'h100;
    
    // 99 instructions from finding the 11th term of Fibonacci sequence
    for(i = 0; i < 90; i = i + 1) begin
      // Fetch
      @(posedge clk) MAR <= PC; we <= 0; cs <= 1; oe <= 1;  // 1
      @(posedge clk) IR <= data; //20
      @(posedge clk) PC <= PC + 2;
      // Decode and execute
      case(IR[15:12])        
        // Load X
        4'b0000: begin
          @(posedge clk) MAR <= IR[11:0]; //1
          @(posedge clk) MBR <= data;  // 20
          @(posedge clk) AC <= MBR; // 1
          $display("loading %d", AC);
        end
        
        // Store X
        4'b0001: begin
          @(posedge clk) MAR <= IR[11:0]; //1
          @(posedge clk) MBR <= AC;   // 1
          $display("storing %d", MBR);
          @(posedge clk) we <= 1; oe <= 0; testbench_data <= MBR;  // 1
        end
        
        // Add X
        4'b0010: begin
          @(posedge clk) MAR <= IR[11:0];
          @(posedge clk) MBR <= data; //20
          @(posedge clk) ALU_Sel <= 'b01; A <= AC; B <= MBR; //3
          $display("%d penis %d", A, B);
          @(posedge clk) AC <= ALU_Out; //1.25
        end
        // Sub X
        4'b0011: begin
          @(posedge clk) MAR <= IR[11:0];
          @(posedge clk) MBR <= data;
          @(posedge clk) ALU_Sel <= 'b10; A <= AC; B <= MBR;
          @(posedge clk) AC <= ALU_Out;
        end
          
          // Jump
        4'b0100: begin
          @(posedge clk) PC <= IR[11:0];
        end
        
        // Load Immediate
        4'b0101: begin
          @(posedge clk) AC <= {{4{IR[11]}}, IR[11:0]};
        end 
        
        // Add Immediate
        4'b0110: begin
          @(posedge clk) ALU_Sel <= 'b01; A <= AC; B <= {{4{IR[11]}}, IR[11:0]};
        end 
        // And 
       	4'b0111: begin
          @(posedge clk) MAR <= IR[11:0];
          @(posedge clk) MBR <= data; 
          @(posedge clk) ALU_Sel <= 'b00; A <= AC; B <= MBR; 
          @(posedge clk) AC <= ALU_Out; 
        end 
        // And Immediate
       	4'b1000: begin
          @(posedge clk) ALU_Sel <= 'b00; A <= AC; B <= {{4{IR[11]}}, IR[11:0]};
        end 
        // Or
        4'b1001: begin
          @(posedge clk) MAR <= IR[11:0];
          @(posedge clk) MBR <= data; 
          @(posedge clk) ALU_Sel <= 'b11; A <= AC; B <= MBR; 
          @(posedge clk) AC <= ALU_Out; 
        end 
        // Or Immediate
        4'b1010: begin
          @(posedge clk) ALU_Sel <= 'b11; A <= AC; B <= {{4{IR[11]}}, IR[11:0]};
        end 
        // Not
 		4'b1011: begin
          @(posedge clk) AC <= !AC;
        end 
          
        // Vector Add
        4'b1100: begin
          reg [add_width - 1 : 0] temp_addr; 
          integer j;
          @(posedge clk) begin
              temp_addr = IR[11:0]; // Starting address
              for (j = 0; j < 4; i = j + 1) begin
                  @(posedge clk) MAR <= temp_addr; // Set address
                  @(posedge clk) MBR <= data; // Fetch data
                  @(posedge clk) ALU_Sel <= 'b01; A <= AC; B <= MBR;
                  @(posedge clk) AC <= ALU_Out;
                  temp_addr = temp_addr + 2; // Move to next address
        	  end
    	   end
        end 
          
        // Clear
        4'b1101: begin
          @(posedge clk) AC <= 0;
        end
         
         // Skip
        4'b1110: begin
          @(posedge clk) 
          if(IR[11:10]==2'b01 && AC == 0) PC <= PC + 2;
          else if(IR[11:10]==2'b00 && AC < 0) PC <= PC + 2;
          else if(IR[11:10]==2'b10 && AC > 0) PC <= PC + 2;
        end
        
        // Halt
        4'b1111: begin
          @(posedge clk) PC <= PC - 2;
        end
        
      endcase
    end
    @(posedge clk) MAR <= 'h10D; we <= 0; cs <= 1; oe <= 1;
    @(posedge clk)    
   #20 $finish;
  end
endmodule

    