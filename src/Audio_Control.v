// PWM output to audio jack
// Continuously outputs the input value using PWM to the audio jack PWM pin
// Author: Ross MacArthur

module Audio_Control (
  input clk,
  input rst,
  input [7:0] value, // the input signed amplitude
  output reg AUD_PWM // the pin to PWM
);

reg [7:0] count;

always @(posedge clk) begin
  if (rst) begin
    count <= 8'b0;
    AUD_PWM <= 1'b0;
  end else begin
    count <= count + 1'b1;
    AUD_PWM <= (count < value) ? 1'bz : 1'b0;
  end
end

endmodule
