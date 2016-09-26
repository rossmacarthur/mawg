// 16-bit signed frequency demodulator and simple moving average filter
// Author: Ross MacArthur

module FMDemodulator (
  input clk,
  input rst,
  input [15:0] modulated,   // signed modulated input
  input [31:0] ctr_ctrl,    // frequency control for center modulating frequency
  input [4:0] sample_rate,  // rate to take samples for demodulation
  output [15:0] demodulated // signed FM demodulated output
);

// XOR center frequency sine wave and modulated wave
wire [31:0] nco_phase;
wire [15:0] nco_out;
wire [15:0] xored;
wire [15:0] demod;

assign xored = nco_out ^ modulated;
assign demod = {~xored[15], xored[14:0]};

// Connect up modules
NCO_fm NCO_fm0 (
  .clk     ( clk       ), // input
  .rst     ( rst       ), // input
  .ctrl    ( ctr_ctrl  ), // input [31:0]
  .phase   ( nco_phase ), // output [31:0]
  .sin_out ( nco_out   )  // output [15:0]
);

BlockAverager BlockAverager0 (
  .clk         ( clk         ), // input
  .phase       ( nco_phase   ), // input [31:0]
  .sample_rate ( sample_rate ), // input [4:0]
  .signal      ( demod       ), // input [15:0]
  .filtered    ( demodulated )  // output [15:0]
);

endmodule
