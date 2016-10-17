// Pulse wave generator
// Author: Ross MacArthur
//   N-bit input frequency control
//   M-bit signed output amplitude
//   N-bit input duty cycle control
//   frequency = clk * ctrl / 2^32
//   duty cycle = duty / 2^32

module Pulse #(N = 32, M = 16)(
  input clk,
  input rst,
  input [N-1:0] ctrl,      // frequency control word
  input [N-1:0] duty,      // duty cycle control word
  output reg [M-1:0] value // signed amplitude of pulse wave
);

reg [N-1:0] phase;

always @(posedge clk) begin
  if (rst) begin
    phase <= {N{1'b0}};
    value <= {M{1'b0}};
  end else begin
    phase <= phase + ctrl;
    value <= (phase < duty) ? {1'b0,{M-1{1'b1}}} : {1'b1,{M-2{1'b0}},1'b1};
  end
end

endmodule
