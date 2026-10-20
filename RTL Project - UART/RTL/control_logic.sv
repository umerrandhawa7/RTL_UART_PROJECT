
// CONTROL LOGIC
module control_logic (
  input logic clk,
  input logic rst,

  // RX FIFO interface
  input  logic [7:0] rx_fifo_data,
  input  logic rx_empty,
  output logic rx_read,

  // TX FIFO interface
  input  logic tx_full,
  output logic tx_write,

  // Memory control/address interface
  output logic mem_write,
  output logic [3:0] mem_write_addr,
  output logic [3:0] mem_read_addr,

  output logic out_of_bounds
);

typedef enum logic [3:0] {
  IDLE, START, DATA, WRITE, READ, WAIT, SEND, DISCARD, STOP
} state_t;

state_t current_state, next_state;

logic [7:0] command_reg;
logic [2:0] data_count;
logic [2:0] discard_count;
logic [3:0] address;

// Current-state register
always_ff @(posedge clk) begin
  if (rst)
    current_state <= IDLE;
  else
    current_state <= next_state;
end

// Next-state logic
always_comb begin
  next_state = current_state;

  case (current_state)
    IDLE: begin
      if (!rx_empty)
        next_state = START;
    end

    START: begin
      if (command_reg[7:5] == 0)
        next_state = STOP;
      else if (command_reg[0] == 1'b1)
        next_state = DATA;  // write command
      else
        next_state = READ;  // read command
    end

    DATA: begin
      if (!rx_empty)
        next_state = WRITE;
    end

    WRITE: begin
      if (data_count == 1)
        next_state = STOP;
      else if (address == 15)
        next_state = DISCARD;
      else
        next_state = DATA;
    end

    READ: next_state = WAIT;
    WAIT: next_state = SEND;

    SEND: begin
      if (!tx_full) begin
        if ((data_count == 1) || (address == 15))
          next_state = STOP;
        else
          next_state = READ;
      end
    end

    DISCARD: begin
      if ((discard_count == 0) ||
          (!rx_empty && (discard_count == 1)))
        next_state = STOP;
    end

    STOP: next_state = IDLE;
    default: next_state = IDLE;
  endcase
end

// Control outputs and control register update
always_ff @(posedge clk) begin
  if (rst) begin
    command_reg  <= 8'b0;
    data_count   <= 3'b0;
    discard_count <= 3'b0;
    address      <= 4'b0;
    out_of_bounds <= 1'b0;
  end else begin
    if ((current_state == IDLE) && !rx_empty) begin
      command_reg <= rx_fifo_data;
      out_of_bounds <= 1'b0;
    end

    if (current_state == START) begin
      data_count <= command_reg[7:5];
      address    <= command_reg[4:1];
    end

    if (current_state == WRITE) begin
      if (data_count > 1) begin
        data_count <= data_count - 1'b1;
        if (address == 15) begin
          out_of_bounds <= 1'b1;
          discard_count <= data_count - 1'b1;
        end else begin
          address <= address + 1'b1;
        end
      end
    end

    if ((current_state == SEND) && !tx_full) begin
      if (data_count > 1) begin
        data_count <= data_count - 1'b1;
        if (address == 15)
          out_of_bounds <= 1'b1;
        else
          address <= address + 1'b1;
      end
    end

    if ((current_state == DISCARD) &&
        !rx_empty && (discard_count != 0)) begin
      discard_count <= discard_count - 1'b1;
    end
  end
end

always_comb begin
  rx_read  = 1'b0;
  tx_write = 1'b0;
  mem_write = 1'b0;

  if ((current_state == IDLE) && !rx_empty)
    rx_read = 1'b1;

  if (current_state == WRITE) begin
    rx_read  = 1'b1;
    mem_write = 1'b1;
  end

  if ((current_state == DISCARD) &&
      !rx_empty && (discard_count != 0))
    rx_read = 1'b1;

  if ((current_state == SEND) && !tx_full)
    tx_write = 1'b1;
end

assign mem_write_addr = address;
assign mem_read_addr  = address;

endmodule
