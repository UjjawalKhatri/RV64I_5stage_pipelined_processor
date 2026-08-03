// ============================================================================
// Module: pc
// Description: Program Counter for RV64I Pipelined Processor
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire        pc_write,
    input  wire [63:0] pc_in,
    output reg  [63:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 64'h0;
        end else if (pc_write) begin
            pc_out <= pc_in;
        end
    end

endmodule
