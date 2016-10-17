// Sawtooth wave generator
// Author: Ross MacArthur
//   N-bit input frequency control
//   M-bit signed output amplitude
//   frequency = clk * ctrl / 2^32

module Sawtooth #(N = 32, M = 16)(
  input clk,
  input rst,
  input [N-1:0] ctrl,      // frequency control word
  output reg [M-1:0] value // signed amplitude of sawtooth wave
);

reg [N-1:0] phase;

always @(posedge clk) begin
  if (rst) begin
    phase <= {N{1'b0}};
    value <= {M{1'b0}};
  end else begin
    phase <= phase + ctrl;
    value <= {~phase[N-1], phase[N-2:M]};
  end
end

endmodule
