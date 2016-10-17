// Modulation and arbitrary waveform generator
// Author: Ross MacArthur
//   16-bit signed output amplitude
//   Four different waveforms: sine, chirp, sawtooth, pulse
//   Three different output options: raw waveform, modulated, demodulated

module MAWG (
  input clk,
  input rst,
  input [1:0] out_sel,           // waveform = 0b00, modulated = 0b01, demodulated = 0b10
  input [1:0] wave_sel,          // nco = 0b00, chirp = 0b01, sawtooth = 0b10, pulse = 0b11
  input [31:0] freq_ctrl,        // frequency control word
  input chirp_reverse,           // whether chirp is an up (0) or a down (1) chirp
  input [7:0] chirp_delay,       // delay control between chirps
  input [31:0] chirp_min_ctrl,   // minimum frequency control word
  input [31:0] chirp_max_ctrl,   // maximum frequency control word
  input [31:0] chirp_inc_rate,   // proportional frequency rate control word
  input [31:0] chirp_div_rate,   // inversely proportional frequency rate control word
  input [31:0] pulse_duty_cycle, // duty cycle of pulse waveform
  input [31:0] fm_ctr_ctrl,      // FM center frequency control word
  input [7:0] fm_deviation,      // FM deviation from center frequency control word
  input [4:0] fm_demod_rate,     // Controls sample rate of FM demodulator
  output reg [15:0] signal0,     // Signed waveform output
  output [15:0] signal1          // Secondary waveform output (only used for cosine output)
);


// Select output waveform
wire [15:0] waveform0; 
wire [15:0] waveform1;
wire [15:0] modulated;
wire [15:0] demodulated;

assign signal1 = waveform1;

always @(posedge clk) begin
  case(out_sel)
    2'b00 : signal0 <= waveform0;
    2'b01 : signal0 <= modulated;
    2'b10 : signal0 <= demodulated;
    default : signal0 <= 16'h0;
  endcase
end

// Connect up modules
WaveGenerator WaveGenerator0 (
  .clk              ( clk              ), // input
  .rst              ( rst              ), // input
  .wave_sel         ( wave_sel         ), // input [1:0]
  .freq_ctrl        ( freq_ctrl        ), // input [31:0]
  .chirp_reverse    ( chirp_reverse    ), // input
  .chirp_delay      ( chirp_delay      ), // input [3:0]
  .chirp_min_ctrl   ( chirp_min_ctrl   ), // input [31:0]
  .chirp_max_ctrl   ( chirp_max_ctrl   ), // input [31:0]
  .chirp_inc_rate   ( chirp_inc_rate   ), // input [31:0]
  .chirp_div_rate   ( chirp_div_rate   ), // input [31:0]
  .pulse_duty_cycle ( pulse_duty_cycle ), // input [31:0]
  .waveform0        ( waveform0        ), // output [15:0]
  .waveform1        ( waveform1        )  // output [15:0]
);

FMModulator FMModulator0 (
  .clk       ( clk          ), // input
  .rst       ( rst          ), // input
  .message   ( waveform0    ), // input [15:0]
  .ctr_ctrl  ( fm_ctr_ctrl  ), // input [31:0]
  .deviation ( fm_deviation ), // input [7:0]
  .modulated ( modulated    )  // output [15:0]
);

FMDemodulator FMDemodulator0 (
  .clk         ( clk           ), // input
  .rst         ( rst           ), // input
  .modulated   ( modulated     ), // input [15:0]
  .ctr_ctrl    ( fm_ctr_ctrl   ), // input [31:0]
  .sample_rate ( fm_demod_rate ), // input [4:0]
  .demodulated ( demodulated   )  // output [15:0]
);

endmodule
