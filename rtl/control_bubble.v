// ============================================================================
// Module: control_bubble
// Description: NOP multiplexer for injecting control bubbles on load-use stalls
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module control_bubble (
    input  wire       branch_in,
    input  wire       jump_in,
    input  wire       jalr_in,
    input  wire       mem_read_in,
    input  wire       mem_to_reg_in,
    input  wire       mem_write_in,
    input  wire       alu_src_in,
    input  wire       reg_write_in,
    input  wire [3:0] alu_ctrl_in,
    input  wire       sel,
    output wire       branch_out,
    output wire       jump_out,
    output wire       jalr_out,
    output wire       mem_read_out,
    output wire       mem_to_reg_out,
    output wire       mem_write_out,
    output wire       alu_src_out,
    output wire       reg_write_out,
    output wire [3:0] alu_ctrl_out
);

    assign branch_out     = sel ? 1'b0 : branch_in;
    assign jump_out       = sel ? 1'b0 : jump_in;
    assign jalr_out       = sel ? 1'b0 : jalr_in;
    assign mem_read_out   = sel ? 1'b0 : mem_read_in;
    assign mem_to_reg_out = sel ? 1'b0 : mem_to_reg_in;
    assign mem_write_out  = sel ? 1'b0 : mem_write_in;
    assign alu_src_out    = sel ? 1'b0 : alu_src_in;
    assign reg_write_out  = sel ? 1'b0 : reg_write_in;
    assign alu_ctrl_out   = sel ? 4'b0 : alu_ctrl_in;

endmodule
