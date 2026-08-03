// ============================================================================
// Module: ld_after_sd_forwarding
// Description: Direct forwarding from MEM/WB load result to EX/MEM store data
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module ld_after_sd_forwarding (
    input  wire [4:0] ld_rd,
    input  wire [4:0] sd_rs2,
    input  wire       ld_mem_to_reg,
    input  wire       sd_mem_write,
    output wire       ld_sd_sel
);

    assign ld_sd_sel = ld_mem_to_reg && sd_mem_write &&
                       (ld_rd != 5'b0) && (ld_rd == sd_rs2);

endmodule
