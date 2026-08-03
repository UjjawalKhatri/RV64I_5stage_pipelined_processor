// ============================================================================
// Module: EX_MEM
// Description: EX/MEM Pipeline Register
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module EX_MEM (
    input  wire        clk,
    input  wire        reset,
    input  wire        ex_mem_to_reg,
    input  wire        ex_reg_write_en,
    input  wire        ex_mem_read,
    input  wire        ex_mem_write,
    input  wire [63:0] ex_alu_out,
    input  wire [63:0] ex_store_data,
    input  wire [4:0]  ex_rs2,
    input  wire [4:0]  ex_rd,

    output reg         mem_mem_to_reg,
    output reg         mem_reg_write_en,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg  [63:0] mem_alu_out,
    output reg  [63:0] mem_store_data,
    output reg  [4:0]  mem_rs2,
    output reg  [4:0]  mem_rd
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_mem_to_reg   <= 1'b0;
            mem_reg_write_en <= 1'b0;
            mem_mem_read     <= 1'b0;
            mem_mem_write    <= 1'b0;
            mem_alu_out      <= 64'b0;
            mem_store_data   <= 64'b0;
            mem_rs2          <= 5'b0;
            mem_rd           <= 5'b0;
        end else begin
            mem_mem_to_reg   <= ex_mem_to_reg;
            mem_reg_write_en <= ex_reg_write_en;
            mem_mem_read     <= ex_mem_read;
            mem_mem_write    <= ex_mem_write;
            mem_alu_out      <= ex_alu_out;
            mem_store_data   <= ex_store_data;
            mem_rs2          <= ex_rs2;
            mem_rd           <= ex_rd;
        end
    end

endmodule
