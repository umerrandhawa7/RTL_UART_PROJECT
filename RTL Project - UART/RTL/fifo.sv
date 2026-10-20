
// FIFO
module fifo (
  input  logic       clk,
  input  logic       rst,
  input  logic [7:0] data_in,
  input  logic       write_en,
  input  logic       read_en,
  output logic [7:0] data_out,
  output logic       empty,
  output logic       full
);

  logic [7:0] memory [0:15];
  logic [3:0] write_ptr;
  logic [3:0] read_ptr;
  logic [4:0] count;

  assign data_out = memory[read_ptr];
  assign empty = (count == 0);
  assign full  = (count == 16);

  always_ff @(posedge clk) begin
    if (rst) begin
      write_ptr <= 0;
      read_ptr  <= 0;
      count     <= 0;
    end else begin
      if (write_en && !full) begin
        memory[write_ptr] <= data_in;
        write_ptr <= write_ptr + 1'b1;
      end

      if (read_en && !empty)
        read_ptr <= read_ptr + 1'b1;

      if ((write_en && !full) && !(read_en && !empty))
        count <= count + 1'b1;
      else if (!(write_en && !full) && (read_en && !empty))
        count <= count - 1'b1;
    end
  end
endmodule
