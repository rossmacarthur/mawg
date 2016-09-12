// Sawtooth wave generator module
// Author: Ross MacArthur
//   8-bit signed output amplitude
//   32-bit input frequency control
//   frequency = clk * ctrl / 2^32

module Sawtooth (
    input clk,
    input [31:0] ctrl,     // frequency control word
    output reg [7:0] value // signed amplitude of sawtooth wave
);

reg [31:0] phase;

always @(posedge clk) begin
    phase <= phase + ctrl;
    value <= {~phase[31], phase[30:24]};
end

endmodule
