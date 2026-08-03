// ============================================================================
// Module: Instruction_Memory
// Description: 4KB Byte-Addressed Instruction Memory for Vivado Synthesis & Simulation
// Compatible with Xilinx Vivado (Block RAM / Distributed RAM inference)
// ============================================================================
`timescale 1ns / 1ps

module Instruction_Memory #(
    parameter MEM_FILE = "instructions.txt"
)(
    input  wire [63:0] addr,
    output wire [31:0] instr
);

    reg [7:0] memory [4095:0];
    integer i;

    initial begin
        // 1. Initialize memory to 0
        for (i = 0; i < 4096; i = i + 1) begin
            memory[i] = 8'h00;
        end

        // 2. Pre-load default Fibonacci program (ensures Synthesis never fails if text file is missing)
        memory[0]  = 8'h00; memory[1]  = 8'h50; memory[2]  = 8'h01; memory[3]  = 8'h13; // addi x1, x0, 10
        memory[4]  = 8'h00; memory[5]  = 8'hA0; memory[6]  = 8'h01; memory[7]  = 8'h93; // addi x2, x0, 0
        memory[8]  = 8'h00; memory[9]  = 8'h31; memory[10] = 8'h00; memory[11] = 8'hB3; // addi x3, x0, 1
        memory[12] = 8'h40; memory[13] = 8'h31; memory[14] = 8'h01; memory[15] = 8'h33; // addi x1, x1, -1
        memory[16] = 8'h00; memory[17] = 8'h31; memory[18] = 8'hF2; memory[19] = 8'h33; // beq x1, x0, 20
        memory[20] = 8'h00; memory[21] = 8'h41; memory[22] = 8'hF2; memory[23] = 8'hB3; // add x4, x2, x3
        memory[24] = 8'h00; memory[25] = 8'h41; memory[26] = 8'h63; memory[27] = 8'h33; // addi x2, x3, 0
        memory[28] = 8'h00; memory[29] = 8'h31; memory[30] = 8'h63; memory[31] = 8'hB3; // addi x3, x4, 0
        memory[32] = 8'h00; memory[33] = 8'h12; memory[34] = 8'hB0; memory[35] = 8'h23; // beq x0, x0, -20

        // 3. Attempt $readmemh if text file is provided in project
        // synthesis translate_off
        $readmemh(MEM_FILE, memory);
        // synthesis translate_on
    end

    // Big-Endian 32-bit instruction fetch
    wire [11:0] base_addr = addr[11:0];
    assign instr = {memory[base_addr],
                    memory[base_addr + 12'd1],
                    memory[base_addr + 12'd2],
                    memory[base_addr + 12'd3]};

endmodule
