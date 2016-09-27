// Chirp wave generator
// Works in conjunction with sinusoid generator
// Author: Ross MacArthur
//   chirp length = clk * inc_rate / (div_rate * (fmax - fmin))
//     fmax = clk * max_ctrl / 2^32
//     fmin = clk * min_ctrl / 2^32
//   delay is the number of chirp lengths to delay between each chirp

module Chirp (
  input clk,
  input rst,
  input [3:0] delay,         // delay control between chirps
  input is_down,             // whether chirp is an up (0) or a down (1) chirp
  input [31:0] min_ctrl,     // minimum frequency control word
  input [31:0] max_ctrl,     // maximum frequency control word
  input [31:0] inc_rate,     // proportional frequency rate control word
  input [31:0] div_rate,     // inversely proportional frequency rate control word
  output reg nco_reset,      // NCO reset pin
  output reg [31:0] nco_ctrl // NCO frequency control word
);

wire [31:0] stt_ctrl;
wire [31:0] end_ctrl;
wire end_come;

assign stt_ctrl = is_down ? max_ctrl : min_ctrl;
assign end_ctrl = is_down ? min_ctrl : max_ctrl;
assign end_come = is_down ? (nco_ctrl <= end_ctrl) : (nco_ctrl >= end_ctrl);

reg [31:0] rate_count;
reg [3:0] delay_count;

always @(posedge clk) begin
  if (rst) begin
    rate_count <= 32'b0;
    delay_count <= 4'b0;
    nco_reset <= 1'b1;
    nco_ctrl <= 32'b0;
  end else begin
    if (end_come) begin
      nco_ctrl <= stt_ctrl;
      rate_count <= rate_count + 1'b1;
    end else if (rate_count >= div_rate) begin
      nco_ctrl <= is_down ? nco_ctrl - inc_rate : nco_ctrl + inc_rate;
      rate_count <= 32'b0;
    end else
      rate_count <= rate_count + 1'b1;
    
    if (end_come) begin
      if (delay_count >= delay)
        delay_count <= 4'b0;
      else
        delay_count <= delay_count + 1'b1;
    end
    nco_reset <= |delay_count;
  end
end

endmodule
