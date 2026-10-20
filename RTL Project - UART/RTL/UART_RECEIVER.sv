// UART RECEIVER
module uart_rx (
  input  logic       clk,
  input  logic       rst,
  input  logic       rx,
  output logic [7:0] data,
  output logic       valid
);

  typedef enum logic [1:0] { IDLE, START, DATA, STOP } state_t;
  state_t current_state, next_state;

  logic [7:0] shift_reg;
  logic [3:0] count;

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
      IDLE:  if (rx == 1'b0) next_state = START;
      START:                  next_state = DATA;
      DATA:  if (count == 7)  next_state = STOP;
      STOP:                   next_state = IDLE;
      default:                next_state = IDLE;
    endcase
  end

  // Datapath and outputs
  always_ff @(posedge clk) begin
    if (rst) begin
      shift_reg <= 8'b0;
      count     <= 0;
      data      <= 8'b0;
      valid     <= 1'b0;
    end else begin
      valid <= 1'b0;
      case (current_state)
        IDLE: count <= 0;
        START: begin
          count     <= 0;
          shift_reg <= 8'b0;
        end
        DATA: begin
          shift_reg[count] <= rx;
          if (count == 7)
            count <= 0;
          else
            count <= count + 1'b1;
        end
        STOP: begin
          if (rx == 1'b1) begin
            data  <= shift_reg;
            valid <= 1'b1;
          end
          count <= 0;
        end
        default: count <= 0;
      endcase
    end
  end
endmodule
