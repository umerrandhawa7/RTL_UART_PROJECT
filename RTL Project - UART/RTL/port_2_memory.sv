
// 2 PORT MEMORY
module memory_2port (
input logic clk,
input logic rst,

input logic write_en,
input logic [3:0] write_addr,
input logic [7:0] write_data,

input  logic [3:0] read_addr,
output logic [7:0] read_data
);

logic [7:0] memory [0:15];

always_ff @(posedge clk) begin
if (!rst && write_en)
    memory[write_addr] <= write_data;
end

assign read_data = memory[read_addr];

endmodule
