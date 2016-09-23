// Pulse wave generator
// Author: Ross MacArthur
//   16-bit signed output amplitude
//   32-bit input frequency control
//   32-bit input duty cycle control
//   frequency = clk * ctrl / 2^32
//   duty cycle = duty / 2^32

module Pulse (
  input clk,
  input rst,
  input [31:0] ctrl,      // frequency control word
  input [31:0] duty,      // duty cycle control word
  output reg [15:0] value // signed amplitude of pulse wave
);

reg [31:0] phase;

always @(posedge clk) begin
  if (rst) begin
    phase <= 32'b0;
    value <= 16'b0;
  end else begin
    phase <= phase + ctrl;
    value <= (phase < duty) ? 16'b0111_1111_1111_1111 : 16'b1000_0000_0000_0001;
  end
end

endmodule
