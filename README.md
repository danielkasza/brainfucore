# Brainfuck in Verilog

_Daniel Kasza - daniel@kasza.hu_

## Assembler

For efficient execution, the Brainfuck code has to be converted to bytecode.
The assembler does this work. It was written in Python and you will find it in the `assembler` directory.

## C Prototype

The `prototype` directory contains a virtual machine that can execute the bytecode.
This program is very similar to the Verilog implementation, and it is in fact cycle accurate.

## Verilog Implementation

The actual _BrainfuCORE_ source is in the `verilog` directory.

## The Bytecode

Each bytecode instruction is 16b long. The top 3 bits are the opcode, and the bottom 13 bits are the argument.
The 8 opcodes correspond to the 8 Brainfuck commands. The argument is used to improve efficiency by encoding jump
targets for `[` and `]` commands, and by encoding multiple other commands as a single command.

| opcode  | command  | argument  |
|--------:|:--------:|-----------|
|       0 |      `+` | number to add to data, bit 8 to 12 reserved (0) |
|       1 |      `-` | number to subtract from data, bit 8 to 12 reserved (0) |
|       2 |      `>` | number to add to data pointer |
|       3 |      `<` | number to subtract from data pointer |
|       4 |      `.` | reserved, must be 0 |
|       5 |      `,` | reserved, must be 0 |
|       6 |      `[` | jump target if data is 0 |
|       7 |      `]` | jump target if data is not 0 |

Additionally, instruction `0x0000` ends the execution of the program.

Observations:
 * The size of the argument limits the program size to 8192 instructions.
 * `<`, `>`, `+`, `-` use the argument to encode repeated instructions. This significantly reduces the size of programs.
 * `<`, `>`, `-` are all no-ops when the argument is 0.
 * `+` ends the program when the argument is 0.
 * `-` is redundant because it could be represented using `+`. It is included to allow decompression of the bytecode to brainfuck source.

## Limitations

1. Program size is limited to 8192 instructions.
2. The array size is limited to 65536 cells.
