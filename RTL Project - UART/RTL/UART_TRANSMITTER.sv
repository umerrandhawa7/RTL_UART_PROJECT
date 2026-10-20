// UART TRANSMITTER
module uart_tx (
  input  logic       clk,
  input  logic       rst,
  input  logic [7:0] data,
  input  logic       start,
  output logic       tx,
  output logic       busy
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
      IDLE:  if (start)    next_state = START;
      START:               next_state = DATA;
      DATA:  if (count==7) next_state = STOP;
      STOP:                next_state = IDLE;
      default:             next_state = IDLE;
    endcase
  end

  // Datapath and outputs
  always_ff @(posedge clk) begin
    if (rst) begin
      shift_reg <= 8'b0;
      count     <= 0;
      tx        <= 1'b1;
      busy      <= 1'b0;
    end else begin
      case (current_state)
        IDLE: begin
          tx    <= 1'b1;
          busy  <= 1'b0;
          count <= 0;
          if (start)
            shift_reg <= data;
        end
        START: begin
          tx    <= 1'b0;
          busy  <= 1'b1;
          count <= 0;
        end
        DATA: begin
          tx   <= shift_reg[count];
          busy <= 1'b1;
          if (count == 7)
            count <= 0;
          else
            count <= count + 1'b1;
        end
        STOP: begin
          tx    <= 1'b1;
          busy  <= 1'b1;
          count <= 0;
        end
        default: begin
          tx    <= 1'b1;
          busy  <= 1'b0;
          count <= 0;
        end
      endcase
    end
  end
endmodule