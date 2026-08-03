// ============================================================================
// Module: MEM_WB
// Description: MEM/WB Pipeline Register
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module MEM_WB (
    input  wire        clk,
    input  wire        reset,
    input  wire        wb_mem_to_reg_in,
    input  wire        wb_reg_write_en_in,
    input  wire [63:0] wb_mem_data_in,
    input  wire [63:0] wb_alu_out_in,
    input  wire [4:0]  wb_rd_in,

    output reg         wb_mem_to_reg,
    output reg         wb_reg_write_en,
    output reg  [63:0] wb_mem_data,
    output reg  [63:0] wb_alu_out,
    output reg  [4:0]  wb_rd
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_mem_to_reg   <= 1'b0;
            wb_reg_write_en <= 1'b0;
            wb_mem_data     <= 64'b0;
            wb_alu_out      <= 64'b0;
            wb_rd           <= 5'b0;
        end else begin
            wb_mem_to_reg   <= wb_mem_to_reg_in;
            wb_reg_write_en <= wb_reg_write_en_in;
            wb_mem_data     <= wb_mem_data_in;
            wb_alu_out      <= wb_alu_out_in;
            wb_rd           <= wb_rd_in;
        end
    end

endmodule
