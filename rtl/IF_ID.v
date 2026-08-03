// ============================================================================
// Module: IF_ID
// Description: IF/ID Pipeline Register with flush and stall controls
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module IF_ID (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,
    input  wire        IF_ID_write,
    input  wire [63:0] IF_ID_pc_in,
    input  wire [31:0] IF_ID_Ins_in,
    output reg  [63:0] IF_ID_pc_out,
    output reg  [31:0] IF_ID_Ins_out
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            IF_ID_pc_out  <= 64'b0;
            IF_ID_Ins_out <= 32'b0;
        end else if (IF_ID_write) begin
            IF_ID_pc_out  <= IF_ID_pc_in;
            IF_ID_Ins_out <= IF_ID_Ins_in;
        end
    end

endmodule
