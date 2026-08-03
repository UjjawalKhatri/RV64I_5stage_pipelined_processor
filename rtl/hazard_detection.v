// ============================================================================
// Module: hazard_detection_unit
// Description: Hazard Detection Unit with load-use stalls, branch flushes & 2-bit BHT predictor
// Compatible with Xilinx Vivado Synthesis & Implementation
// ============================================================================
`timescale 1ns / 1ps

module hazard_detection_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        ex_mem_read,
    input  wire        cur_mem_write,
    input  wire        cur_mem_read,
    input  wire        branch_taken,
    input  wire        branch_instr,
    input  wire        jump_instr,
    input  wire [63:0] branch_pc,
    input  wire [4:0]  if_id_rs1,
    input  wire [4:0]  if_id_rs2,
    input  wire [4:0]  ex_rd,
    output reg         pc_write,
    output reg         if_id_write,
    output reg         bubble_sel,
    output reg         flush,
    output wire        predicted_taken
);

    // 16-entry 2-bit saturating counter Branch History Table (BHT)
    reg [1:0] bht [0:15];
    integer idx;
    wire [3:0] bht_index = branch_pc[5:2];

    assign predicted_taken = bht[bht_index][1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (idx = 0; idx < 16; idx = idx + 1) begin
                bht[idx] <= 2'b01; // Weakly Not Taken
            end
        end else if (branch_instr) begin
            case (bht[bht_index])
                2'b00: bht[bht_index] <= branch_taken ? 2'b01 : 2'b00;
                2'b01: bht[bht_index] <= branch_taken ? 2'b10 : 2'b00;
                2'b10: bht[bht_index] <= branch_taken ? 2'b11 : 2'b01;
                2'b11: bht[bht_index] <= branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end

    always @(*) begin
        pc_write    = 1'b1;
        if_id_write = 1'b1;
        bubble_sel  = 1'b0;
        flush       = 1'b0;

        // Flush pipeline on taken branch or jump instruction resolved in EX stage
        if ((branch_instr && branch_taken) || jump_instr) begin
            flush = 1'b1;
        end

        // Load-use hazard detection
        if (ex_mem_read && (ex_rd != 5'b0) &&
            ((ex_rd == if_id_rs1) ||
             ((ex_rd == if_id_rs2) && !(cur_mem_read || cur_mem_write)))) begin
            pc_write    = 1'b0;
            if_id_write = 1'b0;
            bubble_sel  = 1'b1;
        end
    end

endmodule
