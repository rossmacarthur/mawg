// Arbitrary waveform generator
// Author: Ross MacArthur
//   M-bit signed output amplitude
//   Four different waveforms:
//     wave_sel at 0b00 generates sine and cosine at waveform0 and waveform1
//     wave_sel at 0b01 generates chirp at waveform0
//     wave_sel at 0b10 generates sawtooth at waveform0
//     wave_sel at 0b11 generates pulse at waveform0

module WaveGenerator #(N = 32, M = 16)(
  input clk,
  input rst,
  input [1:0] wave_sel,           // nco = 0b00, chirp = 0b01, sawtooth = 0b10, pulse = 0b11
  input [N-1:0] freq_ctrl,        // frequency control word
  input chirp_reverse,            // whether chirp is an up (0) or a down (1) chirp
  input [7:0] chirp_delay,        // delay control between chirps
  input [N-1:0] chirp_min_ctrl,   // minimum frequency control word
  input [N-1:0] chirp_max_ctrl,   // maximum frequency control word
  input [N-1:0] chirp_inc_rate,   // proportional frequency rate control word
  input [N-1:0] chirp_div_rate,   // inversely proportional frequency rate control word
  input [N-1:0] pulse_duty_cycle, // duty cycle of pulse waveform
  output reg [M-1:0] waveform0,   // waveform output pins
  output reg [M-1:0] waveform1    // second waveform output pins (only used to output cosine)
);

// Submodule inputs
reg nco_reset;
reg [N-1:0] nco_ctrl;

// Submodule outputs
wire chirp_nco_reset;
wire [N-1:0] chirp_nco_ctrl;
wire [15:0] sin_out;
wire [15:0] cos_out;
wire [M-1:0] saw_out;
wire [M-1:0] pulse_out;

always @(posedge clk) begin
  waveform1 <= (wave_sel == 2'b00) ? cos_out : {M{1'b0}};
  nco_ctrl <= wave_sel[0] ? chirp_nco_ctrl : freq_ctrl;
  nco_reset <= wave_sel[0] ? chirp_nco_reset : rst;
  case(wave_sel)
    2'b00, 2'b01 : waveform0 <= sin_out; 
    2'b10 : waveform0 <= saw_out;
    2'b11 : waveform0 <= pulse_out;
  endcase
end

// Connect up modules
NCO #(.N(N)) NCO0 (
  .clk     ( clk       ), // input
  .rst     ( nco_reset ), // input
  .ctrl    ( nco_ctrl  ), // input [N-1:0]
  .sin_out ( sin_out   ), // output [15:0]
  .cos_out ( cos_out   )  // output [15:0]
);

Chirp #(.N(N)) Chirp0 (
  .clk       ( clk             ), // input
  .rst       ( rst             ), // input
  .delay     ( chirp_delay     ), // input [7:0]
  .reverse   ( chirp_revrse    ), // input
  .min_ctrl  ( chirp_min_ctrl  ), // input [N-1:0]
  .max_ctrl  ( chirp_max_ctrl  ), // input [N-1:0]
  .inc_rate  ( chirp_inc_rate  ), // input [N-1:0]
  .div_rate  ( chirp_div_rate  ), // input [N-1:0]
  .nco_reset ( chirp_nco_reset ), // output
  .nco_ctrl  ( chirp_nco_ctrl  )  // output [N-1:0]
);

Sawtooth #(.N(N), .M(M)) Sawtooth0 (
  .clk   ( clk       ), // input
  .rst   ( rst       ), // input
  .ctrl  ( freq_ctrl ), // input [N-1:0]
  .value ( saw_out   )  // input [M-1:0]
);

Pulse #(.N(N), .M(M)) Pulse0 (
  .clk   ( clk              ), // input
  .rst   ( rst              ), // input  
  .ctrl  ( freq_ctrl        ), // input [N-1:0]
  .duty  ( pulse_duty_cycle ), // input [N-1:0]
  .value ( pulse_out        )  // output [M-1:0]
);

endmodule
