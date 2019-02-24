#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdbool.h>

#define INSTRUCTION_MEMORY_SIZE     8192
#define DATA_MEMORY_SIZE            65536

// Instruction memory.
uint16_t instructions[INSTRUCTION_MEMORY_SIZE] = { 0 };
// Data memory.
uint8_t memory[DATA_MEMORY_SIZE] = { 0 };

int main(int argc, char *argv[]) {
    // Read instructions.
    // Bail as soon as a read fails, or when the memory is full.
    unsigned i;
    for (i=0; i<INSTRUCTION_MEMORY_SIZE; i++) {
        if (scanf("%04" SCNx16, &instructions[i]) != 1) {
            // Failed to read this instruction, stop here.
            break;
        }
    }
    fprintf(stderr, "Read %u instructions.\n\n", i);

    // Execute instructions.
    uint64_t cycles = 0;
    uint16_t pc = 0;
    uint16_t dp = 0;
    for(;;) {
        // Make sure pc wraps correctly.
        pc %= INSTRUCTION_MEMORY_SIZE;

        // Fetch and decode instructions.
        uint16_t instruction = instructions[pc];
        uint8_t opcode = instruction >> 13;
        uint16_t argument = instruction & 0x1FFF;

        // Execute.
        bool jumped = false;
        if (instruction == 0) break;
        switch (opcode) {
            case 0: memory[dp] += argument; break; // +
            case 1: memory[dp] -= argument; break; // -
            case 2: dp += argument; break; // >
            case 3: dp -= argument; break; // <
            case 4: putc(memory[dp], stdout); break; // .
            case 5: memory[dp] = (uint64_t)cycles; break; // ,
            case 6: if (!memory[dp]) pc = argument; break; // [
            case 7: if (memory[dp]) pc = argument; break; // ]
            default:
                fprintf(stderr, "Wat?\n");
                return EXIT_FAILURE;
        }

        pc++;
        cycles++;
    }

    fprintf(stderr, "\nDone in %" PRIu64 " cycles.\n", cycles);

    return EXIT_SUCCESS;
}