module brainfucore;

// Generate a clock for ourselves.
// The FPGA implementation will use an external clock.
reg clock = 0;
always
    #1 clock = ~clock;

reg     [39:0]  cycles = 0;                 // Cycle counter.
reg     [15:0]  instructions    [0: 8191];  // Instruction memory.
reg     [ 7:0]  memory          [0:65535];  // Data memory.
reg     [12:0]  pc = 0;                     // Program counter, next instruction to fetch.
reg     [15:0]  dp = 0;                     // Data pointer, array cell being accessed.

// Initialize memories.
integer i;
initial begin
    for (i=0; i<65536; i++) memory[i]       = 0;
    for (i=0; i< 8192; i++) instructions[i] = 0;

    // Load program.
    $readmemh("program.bfb", instructions);
end

// Do as much works are we can using combinational logic.
wire    [15:0]  instruction = instructions[pc];     // Get instruction at program counter.
wire    [ 2:0]  opcode      = instruction[15:13];   // Extract opcode.
wire    [12:0]  argument    = instruction[12: 0];   // Extract argument.
wire    [ 7:0]  data        = memory[dp];           // Get data at data pointer.
reg     [12:0]  next_pc;                            // Next instruction that will be executed.
reg     [15:0]  next_dp;                            // New value of data pointer.
reg     [ 7:0]  new_data;                           // New value for current data cell.
always@(*) begin
    // Handle +, -, and ',' these change new_data.
    if      (opcode == 0) new_data = data + argument;
    else if (opcode == 1) new_data = data - argument;
    else if (opcode == 5) new_data = cycles;
    else                  new_data = data;

    // Handle > and <, these change next_dp.
    if      (opcode == 2) next_dp = dp + argument;
    else if (opcode == 3) next_dp = dp - argument;
    else                  next_dp = dp;
    
    // Handle [ and ], these change next_pc.
    if      (opcode == 6) next_pc = ((data == 0) ? argument : pc) + 1;
    else if (opcode == 7) next_pc = ((data == 0) ? pc : argument) + 1;
    else                  next_pc = pc + 1;
end

// Use sequential logic to move things forward.
always@(posedge clock) begin
    pc <= next_pc;
    dp <= next_dp;
    memory[dp] <= new_data;

    // Handle '.', this just prints data.
    if (opcode == 4) $write("%c", data);

    // Handle 0 instruction, this ends the program
    if (instruction == 0) begin
        $display("Done in %0d cycles.", cycles);
        $finish;
    end

    cycles <= cycles + 1;
end

endmodule