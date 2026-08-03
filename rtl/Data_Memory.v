// ============================================================================
// Module: Data_Memory
// Description: Word-Addressed 64-bit Data Memory (128 x 64-bit = 1KB)
// Uses Distributed RAM (LUTRAM) with combinational read for pipeline compatibility
// Single write port = clean FPGA RAM inference, no timing violations
// ============================================================================
`timescale 1ns / 1ps

module Data_Memory (
    input  wire        clk,
    input  wire        reset,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [9:0]  address,
    input  wire [63:0] write_data,
    output wire [63:0] read_data
);

    // 128 x 64-bit word-addressed memory (128 words x 8 bytes = 1024 bytes)
    // Distributed RAM: supports combinational (async) read + synchronous write
    (* ram_style = "distributed" *) reg [63:0] Dmemory [127:0];
    integer k;

    // Word address = byte address >> 3 (divide by 8 for 64-bit alignment)
    wire [6:0] word_addr = address[9:3];

    // Power-up initialization
    initial begin
        for (k = 0; k < 128; k = k + 1) begin
            Dmemory[k] = 64'h0;
        end
    end

    // Synchronous single-port write
    always @(posedge clk) begin
        if (MemWrite) begin
            Dmemory[word_addr] <= write_data;
        end
    end

    // Combinational (asynchronous) read — required for pipeline MEM stage
    assign read_data = MemRead ? Dmemory[word_addr] : 64'b0;

endmodule
