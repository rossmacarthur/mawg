// Pulse wave generator module
// Author: Ross MacArthur
//   8-bit signed output amplitude
//   32-bit input frequency control
//   32-bit input duty cycle control
//   frequency = clk * ctrl / 2^32
//   duty cycle = duty / 2^32

module Pulse (
    input clk,
    input [31:0] ctrl,     // frequency control word
    input [31:0] duty,     // duty cycle control word
    output reg [7:0] value // signed amplitude of pulse wave
);

reg [31:0] phase;

always @(posedge clk) begin
    phase <= phase + ctrl;
    value <= (phase < duty) ? 8'b01111111 : 8'b10000001;
end

endmodule
