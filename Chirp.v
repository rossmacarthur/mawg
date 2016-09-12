// Chirp wave generator module
// Works in conjunction with sinusoid generator module
// Author: Ross MacArthur
//   chirp length = clk * inc_rate / (div_rate * (fmax - fmin))
//     fmax = clk * max_ctrl / 2^32
//     fmin = clk * min_ctrl / 2^32
//   delay is the number of chirp lengths to delay between each chirp

module Chirp (
    input clk,
    input [3:0] delay,         // delay control between chirps
    input is_down,             // whether chirp is an up (0) or a down (1) chirp
    input [31:0] min_ctrl,     // minimum frequency control word
    input [31:0] max_ctrl,     // maximum frequency control word
    input [31:0] inc_rate,     // proportional frequency rate control word
    input [31:0] div_rate,     // inversely proportional frequency rate control word
    output reg nco_reset,      // NCO reset pin
    output reg [31:0] nco_ctrl // NCO frequency control word
);

reg [3:0] delay_count;
reg [31:0] stt_ctrl;
reg [31:0] end_ctrl;
reg [31:0] rate_count;
reg end_reached;

always @(posedge clk) begin
    stt_ctrl <= is_down ? max_ctrl : min_ctrl;
    end_ctrl <= is_down ? min_ctrl : max_ctrl;
    end_reached <= is_down ? (nco_ctrl <= end_ctrl) : (nco_ctrl >= end_ctrl);
    
    if (end_reached) begin
        nco_ctrl <= stt_ctrl;
        rate_count <= rate_count + 1'b1;
    end else if (rate_count >= div_rate) begin
        nco_ctrl <= is_down ? nco_ctrl - inc_rate : nco_ctrl + inc_rate;
        rate_count <= 32'h0;
    end else
        rate_count <= rate_count + 1'b1;
    
    if (end_reached) begin
        if (delay_count >= delay)
            delay_count <= 4'b0;
        else
            delay_count <= delay_count + 1'b1;
    end
    
    nco_reset <= |delay_count;
    
end

endmodule
