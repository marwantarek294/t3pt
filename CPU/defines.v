// defines.v
`ifndef DEFINES_V
`define DEFINES_V

// RISC-V Opcodes (RV32I/RV64I)
`define op_lui          7'b0110111
`define op_auipc        7'b0010111
`define jal             7'b1101111
`define jalr            7'b1100111
`define op32_branch     7'b1100011
`define op32_loadop     7'b0000011
`define op32_storeop    7'b0100011
`define op32_alu        7'b0110011
`define op32_imm_alu    7'b0010011
`define op64_alu        7'b0111011
`define op64_imm_alu    7'b0011011
`define op32_muldiv     7'b0110011  // Same as op32_alu, distinguished by funct7
`define op64_muldiv     7'b0111011  // Same as op64_alu, distinguished by funct7
`define amo             7'b0101111
`define sys             7'b1110011
`define op32_fp_loadop  7'b0000111
`define op32_fp_storeop 7'b0100111
`define vsetvl          7'b1010111  // Vector extension opcode

// Function Codes (funct3) for Load/Store Instructions
`define func_lb         3'b000  // Load Byte
`define func_lh         3'b001  // Load Halfword
`define func_lw         3'b010  // Load Word
`define func_ld         3'b011  // Load Doubleword
`define func_lbu        3'b100  // Load Byte Unsigned
`define func_lhu        3'b101  // Load Halfword Unsigned
`define func_lwu        3'b110  // Load Word Unsigned
`define func_sb         3'b000  // Store Byte
`define func_sh         3'b001  // Store Halfword
`define func_sw         3'b010  // Store Word
`define func_sd         3'b011  // Store Doubleword

// Function Codes (funct3) for Branch Instructions
`define func_beq        3'b000
`define func_bne        3'b001
`define func_blt        3'b100
`define func_bge        3'b101
`define func_bltu       3'b110
`define func_bgeu       3'b111

// Function Codes (funct3) for ALU Instructions
`define alu_addsub      3'b000
`define alu_slt         3'b010
`define alu_sltu        3'b011
`define alu_sll         3'b001
`define alu_srlsra      3'b101
`define alu_or          3'b110
`define alu_xor         3'b100
`define alu_and         3'b111

// Function Codes (funct3) for Multiplication/Division
`define func_mul        3'b000
`define func_mulh       3'b001
`define func_mulhsu     3'b010
`define func_mulhu      3'b011
`define func_div        3'b100
`define func_divu       3'b101
`define func_rem        3'b110
`define func_remu       3'b111

// Function Codes (funct7) for ALU and Multiplication/Division
`define func_sub        7'b0100000
`define func_muldiv     7'b0000001

// CSR Addresses
`define vec_len_csr_addr 12'hC20  // Vector length CSR (vlen)
`define mcycle          12'hB00
`define mcycleh         12'hB80
`define minstret        12'hB02
`define minstreth       12'hB82
`define mtime           12'h701
`define mtimeh          12'h741
`define mtimecmp        12'h321
`define mtimecmph       12'h361
`define counttick       12'h320
`define Num_tick        12'h322

`endif