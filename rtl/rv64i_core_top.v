// ============================================================================
// Module: rv64i_core_top
// Description: Top-Level Synthesizable 5-Stage RV64I Pipelined Processor Core
// Compatible with Xilinx Vivado (Artix-7 / Kintex-7 / Zynq FPGAs)
// ============================================================================
`timescale 1ns / 1ps

module rv64i_core_top #(
    parameter MEM_FILE = "instructions.txt"
)(
    input  wire        clk,
    input  wire        reset,
    output wire [63:0] current_pc,
    output wire [31:0] current_instr,
    output wire [63:0] wb_result,
    output wire [4:0]  wb_reg_addr,
    output wire        wb_reg_we,
    output wire [63:0] perf_cycles,
    output wire [63:0] perf_retired,
    output wire [63:0] perf_stalls,
    output wire [63:0] perf_flushes,
    output wire [63:0] perf_cpi_x100
);

    // ------------------------------------------------------------------------
    // Wires & Signals Definition
    // ------------------------------------------------------------------------

    // IF Stage Wires
    wire [63:0] pc_out;
    wire [63:0] pc_plus4;
    wire [63:0] pc_branch;
    wire [63:0] pc_next;
    wire [31:0] instr;
    wire        pc_write_en;
    wire        flush_sig;
    wire        if_id_write_en;

    // IF/ID Pipeline Register Wires
    wire [63:0] if_id_pc;
    wire [31:0] if_id_ins;

    // ID Stage Control & Decoder Wires
    wire        branch, jump, jalr, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0]  alu_op;
    wire [3:0]  alu_ctrl_raw;

    // Control Bubble Wires
    wire        bubble_sel;
    wire        b_branch, b_jump, b_jalr, b_mem_read, b_mem_to_reg, b_mem_write, b_alu_src, b_reg_write;
    wire [3:0]  b_alu_ctrl;

    // ID Register File & Immediate Generator Wires
    wire [63:0] rf_rdata1, rf_rdata2;
    wire [63:0] wb_write_data;
    wire [4:0]  wb_rd;
    wire        wb_reg_write_sig;
    wire [63:0] imm;

    // ID/EX Pipeline Register Wires
    wire        ex_mem_to_reg, ex_reg_write, ex_mem_read, ex_mem_write;
    wire        ex_branch, ex_jump, ex_jalr, ex_alu_src;
    wire [3:0]  ex_alu_ctrl;
    wire [63:0] ex_pc, ex_data1, ex_data2, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;

    // EX Stage Execution & Forwarding Wires
    wire [1:0]  fwd_a, fwd_b;
    wire [63:0] alu_a, alu_b_pre, alu_b;
    wire [63:0] alu_out;
    wire        alu_zero;
    wire        branch_taken;

    // EX/MEM Pipeline Register Wires
    wire        mem_mem_to_reg, mem_reg_write, mem_mem_read, mem_mem_write;
    wire [63:0] mem_alu_out, mem_store_data;
    wire [4:0]  mem_rs2, mem_rd;

    // MEM Stage Memory & Forwarding Wires
    wire        ld_sd_sel;
    wire [63:0] mem_write_data_final;
    wire [63:0] mem_read_data;

    // MEM/WB Pipeline Register Wires
    wire        wb_mem_to_reg;
    wire [63:0] wb_mem_data, wb_alu_out;
    wire [4:0]  wb_rd_sig;

    // Hazard Detection Wires
    wire        predicted_taken;

    // ------------------------------------------------------------------------
    // 1. INSTRUCTION FETCH (IF) STAGE
    // ------------------------------------------------------------------------

    // PC + 4 Adder
    assign pc_plus4 = pc_out + 64'd4;

    // Branch / Jump Target Computation
    assign pc_branch = ex_jalr ? (alu_a + ex_imm) : (ex_pc + ex_imm);

    // Branch Taken Decision (BEQ / BNE / Jump)
    assign branch_taken = (ex_branch && alu_zero) || ex_jump;

    // PC Source Mux (PC+4 vs Branch/Jump target)
    assign pc_next = branch_taken ? pc_branch : pc_plus4;

    // Program Counter Unit
    pc PC_inst (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write_en),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );

    // Instruction Memory
    Instruction_Memory #(
        .MEM_FILE(MEM_FILE)
    ) IMEM_inst (
        .addr(pc_out),
        .instr(instr)
    );

    // IF/ID Pipeline Register
    IF_ID IFID_inst (
        .clk(clk),
        .reset(reset),
        .flush(flush_sig),
        .IF_ID_write(if_id_write_en),
        .IF_ID_pc_in(pc_out),
        .IF_ID_Ins_in(instr),
        .IF_ID_pc_out(if_id_pc),
        .IF_ID_Ins_out(if_id_ins)
    );

    // ------------------------------------------------------------------------
    // 2. INSTRUCTION DECODE (ID) STAGE
    // ------------------------------------------------------------------------

    // Main Control Unit
    control CTRL_inst (
        .opcode(if_id_ins[6:0]),
        .Branch(branch),
        .Jump(jump),
        .Jalr(jalr),
        .MemRead(mem_read),
        .MemToReg(mem_to_reg),
        .ALUOp(alu_op),
        .MemWrite(mem_write),
        .ALUSrc(alu_src),
        .reg_write_en(reg_write)
    );

    // ALU Control Decoder
    alu_control ALUCTRL_inst (
        .ALUOp(alu_op),
        .Ins({if_id_ins[30], if_id_ins[14:12]}),
        .ALUSrc(alu_src),
        .ALUControl(alu_ctrl_raw)
    );

    // Control Bubble Mux
    control_bubble BUBBLE_inst (
        .branch_in(branch),
        .jump_in(jump),
        .jalr_in(jalr),
        .mem_read_in(mem_read),
        .mem_to_reg_in(mem_to_reg),
        .mem_write_in(mem_write),
        .alu_src_in(alu_src),
        .reg_write_in(reg_write),
        .alu_ctrl_in(alu_ctrl_raw),
        .sel(bubble_sel),
        .branch_out(b_branch),
        .jump_out(b_jump),
        .jalr_out(b_jalr),
        .mem_read_out(b_mem_read),
        .mem_to_reg_out(b_mem_to_reg),
        .mem_write_out(b_mem_write),
        .alu_src_out(b_alu_src),
        .reg_write_out(b_reg_write),
        .alu_ctrl_out(b_alu_ctrl)
    );

    // Register File
    register_file RF_inst (
        .clk(clk),
        .reset(reset),
        .reg_write_en(wb_reg_write_sig),
        .read_reg1(if_id_ins[19:15]),
        .read_reg2(if_id_ins[24:20]),
        .write_reg(wb_rd_sig),
        .write_data(wb_write_data),
        .read_data1(rf_rdata1),
        .read_data2(rf_rdata2)
    );

    // Immediate Generator
    Immediate_Generation IMMGEN_inst (
        .instr(if_id_ins),
        .imm(imm)
    );

    // ID/EX Pipeline Register
    ID_EX IDEX_inst (
        .clk(clk),
        .reset(reset),
        .flush(flush_sig),
        .id_mem_to_reg(b_mem_to_reg),
        .id_reg_write_en(b_reg_write),
        .id_mem_read(b_mem_read),
        .id_mem_write(b_mem_write),
        .id_branch(b_branch),
        .id_jump(b_jump),
        .id_jalr(b_jalr),
        .id_alu_src(b_alu_src),
        .id_alu_ctrl(b_alu_ctrl),
        .id_pc(if_id_pc),
        .id_data1(rf_rdata1),
        .id_data2(rf_rdata2),
        .id_imm(imm),
        .id_rs1(if_id_ins[19:15]),
        .id_rs2(if_id_ins[24:20]),
        .id_rd(if_id_ins[11:7]),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_reg_write_en(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_jalr(ex_jalr),
        .ex_alu_src(ex_alu_src),
        .ex_alu_ctrl(ex_alu_ctrl),
        .ex_pc(ex_pc),
        .ex_data1(ex_data1),
        .ex_data2(ex_data2),
        .ex_imm(ex_imm),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd)
    );

    // ------------------------------------------------------------------------
    // 3. EXECUTE (EX) STAGE
    // ------------------------------------------------------------------------

    // Forwarding Unit
    Forwarding_unit FWD_inst (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rd),
        .wb_rd(wb_rd_sig),
        .mem_regwrite(mem_reg_write),
        .wb_regwrite(wb_reg_write_sig),
        .ForwardA(fwd_a),
        .ForwardB(fwd_b)
    );

    // Forwarding Multiplexers
    assign alu_a = (fwd_a == 2'b10) ? mem_alu_out :
                   (fwd_a == 2'b01) ? wb_write_data : ex_data1;

    assign alu_b_pre = (fwd_b == 2'b10) ? mem_alu_out :
                       (fwd_b == 2'b01) ? wb_write_data : ex_data2;

    // ALUSrc Multiplexer
    assign alu_b = ex_alu_src ? ex_imm : alu_b_pre;

    // 64-bit ALU
    alu_64_bit ALU_inst (
        .a(alu_a),
        .b(alu_b),
        .opcode(ex_alu_ctrl),
        .result(alu_out),
        .zero_flag(alu_zero)
    );

    // EX/MEM Pipeline Register
    EX_MEM EXMEM_inst (
        .clk(clk),
        .reset(reset),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_reg_write_en(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_alu_out(alu_out),
        .ex_store_data(alu_b_pre),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write_en(mem_reg_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_alu_out(mem_alu_out),
        .mem_store_data(mem_store_data),
        .mem_rs2(mem_rs2),
        .mem_rd(mem_rd)
    );

    // ------------------------------------------------------------------------
    // 4. MEMORY ACCESS (MEM) STAGE
    // ------------------------------------------------------------------------

    // Load-after-Store Forwarding
    ld_after_sd_forwarding LD_SD_FWD_inst (
        .ld_rd(wb_rd_sig),
        .sd_rs2(mem_rs2),
        .ld_mem_to_reg(wb_mem_to_reg),
        .sd_mem_write(mem_mem_write),
        .ld_sd_sel(ld_sd_sel)
    );

    assign mem_write_data_final = ld_sd_sel ? wb_write_data : mem_store_data;

    // Data Memory
    Data_Memory DMEM_inst (
        .clk(clk),
        .reset(reset),
        .MemRead(mem_mem_read),
        .MemWrite(mem_mem_write),
        .address(mem_alu_out[9:0]),
        .write_data(mem_write_data_final),
        .read_data(mem_read_data)
    );

    // MEM/WB Pipeline Register
    MEM_WB MEMWB_inst (
        .clk(clk),
        .reset(reset),
        .wb_mem_to_reg_in(mem_mem_to_reg),
        .wb_reg_write_en_in(mem_reg_write),
        .wb_mem_data_in(mem_read_data),
        .wb_alu_out_in(mem_alu_out),
        .wb_rd_in(mem_rd),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_reg_write_en(wb_reg_write_sig),
        .wb_mem_data(wb_mem_data),
        .wb_alu_out(wb_alu_out),
        .wb_rd(wb_rd_sig)
    );

    // ------------------------------------------------------------------------
    // 5. WRITE-BACK (WB) STAGE
    // ------------------------------------------------------------------------

    assign wb_write_data = wb_mem_to_reg ? wb_mem_data : wb_alu_out;

    // ------------------------------------------------------------------------
    // 6. HAZARD DETECTION & PERFORMANCE COUNTERS
    // ------------------------------------------------------------------------

    hazard_detection_unit HDU_inst (
        .clk(clk),
        .reset(reset),
        .ex_mem_read(ex_mem_read),
        .cur_mem_write(mem_write),
        .cur_mem_read(mem_read),
        .branch_taken(branch_taken),
        .branch_instr(ex_branch),
        .jump_instr(ex_jump),
        .branch_pc(ex_pc),
        .if_id_rs1(if_id_ins[19:15]),
        .if_id_rs2(if_id_ins[24:20]),
        .ex_rd(ex_rd),
        .pc_write(pc_write_en),
        .if_id_write(if_id_write_en),
        .bubble_sel(bubble_sel),
        .flush(flush_sig),
        .predicted_taken(predicted_taken)
    );

    perf_counters PERF_inst (
        .clk(clk),
        .reset(reset),
        .wb_reg_write(wb_reg_write_sig),
        .wb_rd(wb_rd_sig),
        .stall_active(bubble_sel),
        .flush_active(flush_sig),
        .total_cycles(perf_cycles),
        .retired_instructions(perf_retired),
        .stall_cycles(perf_stalls),
        .flush_cycles(perf_flushes),
        .cpi_x100(perf_cpi_x100)
    );

    // Top-Level Output Assignments for Vivado Monitoring & Synthesis
    assign current_pc    = pc_out;
    assign current_instr = instr;
    assign wb_result     = wb_write_data;
    assign wb_reg_addr   = wb_rd_sig;
    assign wb_reg_we     = wb_reg_write_sig;

endmodule
