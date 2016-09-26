// Debounces a bouncy input
// Author: Ross MacArthur

module Debounce (
  input clk,
  input noisy,
  output debounced
);

assign debounced = d1 & d2 & d3;

reg [18:0] counter;
reg d1, d2, d3;

always @(posedge clk) begin
  if (&counter) begin
    counter <= 19'b0;
    d1 <= noisy;
    d2 <= d1;
    d3 <= d2;
  end else
    counter <= counter + 1'b1;
end

endmodule
