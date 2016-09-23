// 16-bit signed frequency modulator with given center frequency and deviation
// Author: Ross MacArthur

module FMModulator (
  input clk,
  input rst,
  input [15:0] message,   // signed modulating input
  input [31:0] ctr_ctrl,  // frequency control for center modulating frequency
  input [7:0] deviation,  // controls the deviation from the center frequency
  output [15:0] modulated // signed FM modulated output
);

// Vary frequency control using input signal
wire [31:0] crr_ctrl;
wire [47:0] emessage;
wire [47:0] fmessage;

assign emessage = {{32{message[15]}}, message};
assign fmessage = emessage <<< deviation;
assign crr_ctrl = ctr_ctrl + fmessage[47:16];

// Connect up modules
NCO_fm NCO_fm0 (
  .clk     ( clk       ), // input
  .rst     ( rst       ), // input
  .ctrl    ( crr_ctrl  ), // input [31:0]
//.phase   ( nco_phase ), // output [31:0]
  .sin_out ( modulated )  // output [15:0]
);

endmodule
