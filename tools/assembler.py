#!/usr/bin/env python3
"""
============================================================================
RISC-V Assembler & Hex Memory Generator for Vivado
Converts standard RISC-V assembly instructions into 32-bit big-endian byte
hex text format required by Vivado $readmemh Instruction Memory.
============================================================================
"""

import sys
import os

REGISTER_MAP = {
    "zero": 0, "x0": 0,
    "ra": 1,   "x1": 1,
    "sp": 2,   "x2": 2,
    "gp": 3,   "x3": 3,
    "tp": 4,   "x4": 4,
    "t0": 5,   "x5": 5,
    "t1": 6,   "x6": 6,
    "t2": 7,   "x7": 7,
    "s0": 8,   "fp": 8, "x8": 8,
    "s1": 9,   "x9": 9,
    "a0": 10,  "x10": 10,
    "a1": 11,  "x11": 11,
    "a2": 12,  "x12": 12,
    "a3": 13,  "x13": 13,
    "a4": 14,  "x14": 14,
    "a5": 15,  "x15": 15,
    "a6": 16,  "x16": 16,
    "a7": 17,  "x17": 17,
    "s2": 18,  "x18": 18,
    "s3": 19,  "x19": 19,
    "s4": 20,  "x20": 20,
    "s5": 21,  "x21": 21,
    "s6": 22,  "x22": 22,
    "s7": 23,  "x23": 23,
    "s8": 24,  "x24": 24,
    "s9": 25,  "x25": 25,
    "s10": 26, "x26": 26,
    "s11": 27, "x27": 27,
    "t3": 28,  "x28": 28,
    "t4": 29,  "x29": 29,
    "t5": 30,  "x30": 30,
    "t6": 31,  "x31": 31
}

def parse_reg(reg_str):
    reg = reg_str.strip().lower()
    if reg in REGISTER_MAP:
        return REGISTER_MAP[reg]
    elif reg.startswith('x') and reg[1:].isdigit():
        return int(reg[1:])
    else:
        raise ValueError(f"Unknown register: {reg_str}")

def encode_r_type(opcode, funct3, funct7, rd, rs1, rs2):
    val = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return f"{val:08x}"

def encode_i_type(opcode, funct3, rd, rs1, imm):
    imm = imm & 0xFFF
    val = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
    return f"{val:08x}"

def encode_s_type(opcode, funct3, rs1, rs2, imm):
    imm = imm & 0xFFF
    imm_11_5 = (imm >> 5) & 0x7F
    imm_4_0 = imm & 0x1F
    val = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
    return f"{val:08x}"

def encode_b_type(opcode, funct3, rs1, rs2, imm):
    imm = imm & 0x1FFF
    imm_12 = (imm >> 12) & 0x1
    imm_11 = (imm >> 11) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1 = (imm >> 1) & 0xF
    val = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
    return f"{val:08x}"

def assemble_instruction(line):
    line = line.split('#')[0].split('//')[0].strip()
    if not line:
        return None
    
    parts = line.replace(',', ' ').split()
    mnemonic = parts[0].lower()

    if mnemonic == "add":
        return encode_r_type(0x33, 0x0, 0x00, parse_reg(parts[1]), parse_reg(parts[2]), parse_reg(parts[3]))
    elif mnemonic == "sub":
        return encode_r_type(0x33, 0x0, 0x20, parse_reg(parts[1]), parse_reg(parts[2]), parse_reg(parts[3]))
    elif mnemonic == "and":
        return encode_r_type(0x33, 0x7, 0x00, parse_reg(parts[1]), parse_reg(parts[2]), parse_reg(parts[3]))
    elif mnemonic == "or":
        return encode_r_type(0x33, 0x6, 0x00, parse_reg(parts[1]), parse_reg(parts[2]), parse_reg(parts[3]))
    elif mnemonic == "addi":
        return encode_i_type(0x13, 0x0, parse_reg(parts[1]), parse_reg(parts[2]), int(parts[3]))
    elif mnemonic == "ld":
        # Format: ld rd, offset(rs1)
        rd = parse_reg(parts[1])
        offset_reg = parts[2].replace(')', '').split('(')
        offset = int(offset_reg[0])
        rs1 = parse_reg(offset_reg[1])
        return encode_i_type(0x03, 0x3, rd, rs1, offset)
    elif mnemonic == "sd":
        # Format: sd rs2, offset(rs1)
        rs2 = parse_reg(parts[1])
        offset_reg = parts[2].replace(')', '').split('(')
        offset = int(offset_reg[0])
        rs1 = parse_reg(offset_reg[1])
        return encode_s_type(0x23, 0x3, rs1, rs2, offset)
    elif mnemonic == "beq":
        return encode_b_type(0x63, 0x0, parse_reg(parts[1]), parse_reg(parts[2]), int(parts[3]))
    else:
        print(f"Warning: Unsupported mnemonic '{mnemonic}', skipping.")
        return None

def generate_hex_file(assembly_code, output_filepath):
    lines = assembly_code.strip().split('\n')
    hex_instructions = []

    for line in lines:
        hex_val = assemble_instruction(line)
        if hex_val:
            # Convert 32-bit hex into 4 big-endian byte lines for Vivado $readmemh memory
            byte0 = hex_val[0:2]
            byte1 = hex_val[2:4]
            byte2 = hex_val[4:6]
            byte3 = hex_val[6:8]
            hex_instructions.extend([byte0, byte1, byte2, byte3])

    with open(output_filepath, 'w') as f:
        for byte_str in hex_instructions:
            f.write(byte_str + '\n')
    
    print(f"[Assembler] Generated {len(hex_instructions)//4} instructions in Vivado hex format: '{output_filepath}'")

if __name__ == "__main__":
    sample_program = """
    addi x1, x0, 10
    addi x2, x0, 0
    addi x3, x0, 1
    addi x1, x1, -1
    beq  x1, x0, 20
    add  x4, x2, x3
    addi x2, x3, 0
    addi x3, x4, 0
    beq  x0, x0, -20
    """
    output_path = os.path.join(os.path.dirname(__file__), "..", "tb", "instructions.txt")
    generate_hex_file(sample_program, output_path)
