// Sawtooth wave generator
// Author: Ross MacArthur
//   16-bit signed output amplitude
//   32-bit input frequency control
//   frequency = clk * ctrl / 2^32

module Sawtooth (
  input clk,
  input rst,
  input [31:0] ctrl,      // frequency control word
  output reg [15:0] value // signed amplitude of sawtooth wave
);

reg [31:0] phase;

always @(posedge clk) begin
  if (rst) begin
    phase <= 32'b0;
    value <= 16'b0;
  end else begin
    phase <= phase + ctrl;
    value <= {~phase[31], phase[30:16]};
  end
end

endmodule
