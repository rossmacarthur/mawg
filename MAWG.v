module MAWG (
	input clk,
	input [1:0] out_sel,
	input [1:0] wave_sel,
	input [31:0] freq_ctrl,
	input chirp_is_down,
	input [3:0] chirp_delay,
	input [31:0] chirp_min_ctrl,
   input [31:0] chirp_max_ctrl,
   input [31:0] chirp_inc_rate,
   input [31:0] chirp_div_rate,
	input [31:0] pulse_duty_cycle,
	input [31:0] fm_ctr_ctrl,
	input [4:0] fm_deviation,
	output reg [7:0] signal
);

// Select FM message, modulated or demodulated
wire [7:0] message; 
wire [7:0] modulated;
wire [7:0] demodulated;

always @(posedge clk) begin
	case(out_sel)
		2'b00 : signal <= message;
		2'b01 : signal <= modulated;
		2'b10 : signal <= demodulated;
		2'b11 : signal <= 8'b0;
	endcase
end

// Connect up modules
WaveGenerator WaveGenerator0 (
    .clk              ( clk              ), // input
    .wave_sel         ( wave_sel         ), // input [1:0]
    .freq_ctrl        ( freq_ctrl        ), // input [31:0]
    .chirp_is_down    ( chirp_is_down    ), // input
    .chirp_delay      ( chirp_delay      ), // input [3:0]
    .chirp_min_ctrl   ( chirp_min_ctrl   ), // input [31:0]
    .chirp_max_ctrl   ( chirp_max_ctrl   ), // input [31:0]
    .chirp_inc_rate   ( chirp_inc_rate   ), // input [31:0]
    .chirp_div_rate   ( chirp_div_rate   ), // input [31:0]
    .pulse_duty_cycle ( pulse_duty_cycle ), // input [31:0]
    .wave_out         ( message          )  // output [7:0]
//  .wave2_out        (                  )  // output [7:0]
);

FMModulator FMModulator0 (
    .clk       ( clk          ), // input
    .message   ( message      ), // input [7:0]
    .ctr_ctrl  ( fm_ctr_ctrl  ), // input [31:0]
    .deviation ( fm_deviation ), // input [4:0]
    .modulated ( modulated    )  // output [7:0]
);

FMDemodulator FMDemodulator0 (
    .clk         ( clk         ), // input
    .modulated   ( modulated   ), // input [7:0]
    .ctr_ctrl    ( fm_ctr_ctrl ), // input [31:0]
    .demodulated ( demodulated )  // output [7:0]
);

endmodule
