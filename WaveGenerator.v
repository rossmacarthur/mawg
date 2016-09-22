// Arbitrary waveform generator module
// Author: Ross MacArthur
//   16-bit signed output amplitude
//   four different waveforms:
//     wave_sel at 0b00 generates sine and cosine at wave_out and wave2_out
//     wave_sel at 0b01 generates chirp at wave_out
//     wave_sel at 0b10 generates sawtooth at wave_out
//     wave_sel at 0b11 generates pulse at wave_out

module WaveGenerator (
    input clk,
    input [1:0] wave_sel,          // nco = 0b00, chirp = 0b01, sawtooth = 0b10, pulse = 0b11
    input [31:0] freq_ctrl,        // frequency control word
    input chirp_is_down,           // whether chirp is an up (0) or a down (1) chirp
    input [3:0] chirp_delay,       // delay control between chirps
    input [31:0] chirp_min_ctrl,   // minimum frequency control word
    input [31:0] chirp_max_ctrl,   // maximum frequency control word
    input [31:0] chirp_inc_rate,   // proportional frequency rate control word
    input [31:0] chirp_div_rate,   // inversely proportional frequency rate control word
    input [31:0] pulse_duty_cycle, // duty cycle of pulse waveform
    output reg [15:0] wave_out,    // waveform output pins
    output reg [15:0] wave2_out    // second waveform output pins (only used to output cosine)
);

// submodule inputs
reg nco_reset;
reg [31:0] nco_ctrl;
wire [31:0] saw_ctrl;
wire [31:0] pulse_ctrl;

// submodule outputs
wire chirp_nco_reset;
wire [31:0] chirp_nco_ctrl;
wire [15:0] sin_out;
wire [15:0] cos_out;
wire [15:0] saw_out;
wire [15:0] pulse_out;

always @(posedge clk) begin
    wave2_out <= (wave_out == 2'b00) ? cos_out : 16'h0;
    nco_ctrl <= wave_sel[0] ? chirp_nco_ctrl : freq_ctrl;
    nco_reset <= wave_sel[0] ? chirp_nco_reset : 1'b0;
    case(wave_sel)
        2'b00, 2'b01 : wave_out <= sin_out; 
        2'b10 : wave_out <= saw_out;
        2'b11 : wave_out <= pulse_out;
    endcase
end

// Connect up modules
NCO NCO0 (
    .clk     ( clk       ), // input
    .rst     ( nco_reset ), // input
    .ctrl    ( nco_ctrl  ), // input [31:0]
    .sin_out ( sin_out   ), // output [15:0]
    .cos_out ( cos_out   )  // output [15:0]
);

Chirp Chirp0 (
    .clk       ( clk             ), // input
    .delay     ( chirp_delay     ), // input [3:0]
    .is_down   ( chirp_is_down   ), // input
    .min_ctrl  ( chirp_min_ctrl  ), // input [31:0]
    .max_ctrl  ( chirp_max_ctrl  ), // input [31:0]
    .inc_rate  ( chirp_inc_rate  ), // input [31:0]
    .div_rate  ( chirp_div_rate  ), // input [31:0]
    .nco_reset ( chirp_nco_reset ), // output
    .nco_ctrl  ( chirp_nco_ctrl  )  // output [31:0]
);

Sawtooth Sawtooth0 (
    .clk   ( clk       ), // input
    .ctrl  ( freq_ctrl ), // input [31:0]
    .value ( saw_out   )  // input [15:0]
);

Pulse Pulse0 (
    .clk   ( clk              ), // input
    .ctrl  ( freq_ctrl        ), // input [31:0]
    .duty  ( pulse_duty_cycle ), // input [31:0]
    .value ( pulse_out        )  // output [15:0]
);

endmodule
