// ============================================================================
// Module: alu_64_bit
// Description: Fully Behavioral 64-bit ALU for High Performance Vivado Synthesis
// Supports ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, PASS
// ============================================================================
`timescale 1ns / 1ps

module alu_64_bit (
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire [3:0]  opcode,
    output reg  [63:0] result,
    output wire        zero_flag
);

    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_XOR  = 4'b0011;
    localparam ALU_SLL  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;
    localparam ALU_PASS = 4'b1010;

    always @(*) begin
        case (opcode)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_SLL:  result = a << b[5:0];
            ALU_SRL:  result = a >> b[5:0];
            ALU_SRA:  result = $signed(a) >>> b[5:0];
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 64'd1 : 64'd0;
            ALU_SLTU: result = (a < b) ? 64'd1 : 64'd0;
            ALU_PASS: result = b;
            default:  result = 64'b0;
        endcase
    end

    assign zero_flag = (result == 64'b0);

endmodule
