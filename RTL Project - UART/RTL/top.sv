module uart_memory_system(
input logic clk,
input logic rst,
input logic uart_rx,
output logic uart_tx,
output logic out_of_bounds
);

// UART RX
logic [7:0] rx_byte;
logic rx_valid;

// RX FIFO
logic [7:0] rx_fifo_data;
logic rx_fifo_write, rx_fifo_read;
logic rx_fifo_empty, rx_fifo_full;

// TX FIFO
logic [7:0] tx_fifo_data_in, tx_fifo_data_out;
logic tx_fifo_write, tx_fifo_read;
logic tx_fifo_empty, tx_fifo_full;

// Memory interface
logic mem_write;
logic [3:0] mem_write_addr, mem_read_addr;
logic [7:0] mem_read_data;

// UART TX
logic tx_busy;

uart_rx u_uart_rx (
.clk(clk),
.rst(rst),
.rx(uart_rx),
.data(rx_byte),
.valid(rx_valid)
);

assign rx_fifo_write = rx_valid && !rx_fifo_full;

fifo u_rx_fifo (
.clk(clk),
.rst(rst),
.data_in(rx_byte),
.write_en(rx_fifo_write),
.read_en(rx_fifo_read),
.data_out(rx_fifo_data),
.empty(rx_fifo_empty),
.full(rx_fifo_full)
);

control_logic u_control (
.clk(clk),
.rst(rst),
.rx_fifo_data(rx_fifo_data),
.rx_empty(rx_fifo_empty),
.rx_read(rx_fifo_read),
.tx_full(tx_fifo_full),
.tx_write(tx_fifo_write),
.mem_write(mem_write),
.mem_write_addr(mem_write_addr),
.mem_read_addr(mem_read_addr),
.out_of_bounds(out_of_bounds)
);

assign tx_fifo_data_in = mem_read_data;

memory_2port u_memory (
.clk(clk),
.rst(rst),
.write_en(mem_write),
.write_addr(mem_write_addr),
.write_data(rx_fifo_data),  // DIRECT FROM RX FIFO
.read_addr(mem_read_addr),
.read_data(mem_read_data)
);

fifo u_tx_fifo (
.clk(clk),
.rst(rst),
.data_in(tx_fifo_data_in),  // DIRECT FROM MEMORY
.write_en(tx_fifo_write),
.read_en(tx_fifo_read),
.data_out(tx_fifo_data_out),
.empty(tx_fifo_empty),
.full(tx_fifo_full)
);

assign tx_fifo_read = !tx_busy && !tx_fifo_empty;

uart_tx u_uart_tx (
.clk(clk),
.rst(rst),
.data(tx_fifo_data_out),
.start(tx_fifo_read),
.tx(uart_tx),
.busy(tx_busy)
);
endmodule