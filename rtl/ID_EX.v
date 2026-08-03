// ============================================================================
// Module: ID_EX
// Description: ID/EX Pipeline Register
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module ID_EX (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,
    input  wire        id_mem_to_reg,
    input  wire        id_reg_write_en,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire        id_branch,
    input  wire        id_jump,
    input  wire        id_jalr,
    input  wire        id_alu_src,
    input  wire [3:0]  id_alu_ctrl,
    input  wire [63:0] id_pc,
    input  wire [63:0] id_data1,
    input  wire [63:0] id_data2,
    input  wire [63:0] id_imm,
    input  wire [4:0]  id_rs1,
    input  wire [4:0]  id_rs2,
    input  wire [4:0]  id_rd,

    output reg         ex_mem_to_reg,
    output reg         ex_reg_write_en,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg         ex_branch,
    output reg         ex_jump,
    output reg         ex_jalr,
    output reg         ex_alu_src,
    output reg  [3:0]  ex_alu_ctrl,
    output reg  [63:0] ex_pc,
    output reg  [63:0] ex_data1,
    output reg  [63:0] ex_data2,
    output reg  [63:0] ex_imm,
    output reg  [4:0]  ex_rs1,
    output reg  [4:0]  ex_rs2,
    output reg  [4:0]  ex_rd
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ex_mem_to_reg   <= 1'b0;
            ex_reg_write_en <= 1'b0;
            ex_mem_read     <= 1'b0;
            ex_mem_write    <= 1'b0;
            ex_branch       <= 1'b0;
            ex_jump         <= 1'b0;
            ex_jalr         <= 1'b0;
            ex_alu_src      <= 1'b0;
            ex_alu_ctrl     <= 4'b0;
            ex_pc           <= 64'b0;
            ex_data1        <= 64'b0;
            ex_data2        <= 64'b0;
            ex_imm          <= 64'b0;
            ex_rs1          <= 5'b0;
            ex_rs2          <= 5'b0;
            ex_rd           <= 5'b0;
        end else begin
            ex_mem_to_reg   <= id_mem_to_reg;
            ex_reg_write_en <= id_reg_write_en;
            ex_mem_read     <= id_mem_read;
            ex_mem_write    <= id_mem_write;
            ex_branch       <= id_branch;
            ex_jump         <= id_jump;
            ex_jalr         <= id_jalr;
            ex_alu_src      <= id_alu_src;
            ex_alu_ctrl     <= id_alu_ctrl;
            ex_pc           <= id_pc;
            ex_data1        <= id_data1;
            ex_data2        <= id_data2;
            ex_imm          <= id_imm;
            ex_rs1          <= id_rs1;
            ex_rs2          <= id_rs2;
            ex_rd           <= id_rd;
        end
    end

endmodule
