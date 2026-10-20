`timescale 1ns/1ps

module tb_uart_memory_system;

logic clk = 0;
logic rst;
logic uart_rx;
logic uart_tx;
logic out_of_bounds;

uart_memory_system dut (
.clk(clk),
.rst(rst),
.uart_rx(uart_rx),
.uart_tx(uart_tx),
.out_of_bounds(out_of_bounds)
);

always #5 clk = ~clk;

initial begin
$dumpfile("dump.vcd");
$dumpvars(0, tb_uart_memory_system);

rst = 1;
uart_rx = 1;

repeat (5) @(negedge clk);
rst = 0;
repeat (5) @(negedge clk);

// TEST 1: SINGLE BYTE WRITE
// Command 2B: Write one byte to address 5
// Data A5

// Command 2B
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data A5
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1;

repeat (15) @(negedge clk);

// TEST 2: MULTIPLE-BYTE WRITE
// Command 65: Write 3 bytes starting at address 2
// Expected: memory[2]=11, memory[3]=22, memory[4]=33

// Command 65
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data 11
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk); // bit 0
uart_rx = 0; @(negedge clk); // bit 1
uart_rx = 0; @(negedge clk); // bit 2
uart_rx = 0; @(negedge clk); // bit 3
uart_rx = 1; @(negedge clk); // bit 4
uart_rx = 0; @(negedge clk); // bit 5
uart_rx = 0; @(negedge clk); // bit 6
uart_rx = 0; @(negedge clk); // bit 7
uart_rx = 1;
repeat (2) @(negedge clk);

// Data 22
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data 33
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;

repeat (15) @(negedge clk);

// TEST 3: OUT OF BOUNDS WRITE
// Command 5F: Write 2 bytes starting at address 15
// Expected: 55 written to address 15; AA discarded

// Command 5F
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data 55
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data AA: discarded because address 16 is invalid
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1;

repeat (15) @(negedge clk);

// TEST 4: WRITE THEN READ BACK
// Write A5 to address 5, then read address 5

// Write command 2B
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;
repeat (2) @(negedge clk);

// Data A5
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 1;

repeat (15) @(negedge clk);

// Read command 2A
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 0; @(negedge clk);
uart_rx = 1;

repeat (30) @(negedge clk);

// TEST 5: MULTI-BYTE READ
// Command 64: Read 3 bytes starting at address 2
// Expected TX FIFO data: 11, 22, 33

// Send read command 64
uart_rx = 0;
repeat (2) @(negedge clk);
uart_rx = 0; @(negedge clk); // bit 0
uart_rx = 0; @(negedge clk); // bit 1
uart_rx = 1; @(negedge clk); // bit 2
uart_rx = 0; @(negedge clk); // bit 3
uart_rx = 0; @(negedge clk); // bit 4
uart_rx = 1; @(negedge clk); // bit 5
uart_rx = 1; @(negedge clk); // bit 6
uart_rx = 0; @(negedge clk); // bit 7
uart_rx = 1;                 // stop bit

// Wait for all three reads and FIFO writes
repeat (50) @(negedge clk);
$finish;
end
endmodule