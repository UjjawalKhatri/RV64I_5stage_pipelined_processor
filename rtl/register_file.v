// ============================================================================
// Module: register_file
// Description: 32 x 64-bit General Purpose Register File with internal WB write-forwarding
// Optimized for Xilinx Vivado LUTRAM / Distributed RAM Inference
// ============================================================================
`timescale 1ns / 1ps

module register_file (
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write_en,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [63:0] write_data,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2
);

    (* ram_style = "distributed" *) reg [63:0] registers [31:0];
    integer i;

    // Power-up initialization
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'b0;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (reg_write_en && (write_reg != 5'b0)) begin
            registers[write_reg] <= write_data;
        end
    end

    // Combinational read with internal WB write-forwarding
    assign read_data1 = (read_reg1 == 5'b0) ? 64'b0 :
                        (reg_write_en && (write_reg != 5'b0) && (write_reg == read_reg1)) ? write_data :
                        registers[read_reg1];

    assign read_data2 = (read_reg2 == 5'b0) ? 64'b0 :
                        (reg_write_en && (write_reg != 5'b0) && (write_reg == read_reg2)) ? write_data :
                        registers[read_reg2];

endmodule
