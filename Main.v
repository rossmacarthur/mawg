module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

// Select output
wire [7:0] message;
wire [7:0] modulated;
wire [7:0] demodulated;
reg [7:0] to_audio;
always @(*) begin
    if (SW[15:14] == 2'b0)
        to_audio <= message;
    else if (SW[15:14] == 2'b01)
        to_audio <= modulated;
    else
        to_audio <= demodulated;
end

// Connect up modules
WaveGenerator WaveGenerator0 (
    .clk              ( CLK_100M     ), // input
    .wave_sel         ( SW[13:12]    ), // input [1:0]
    .freq_ctrl        ( 32'h49D2     ), // input [31:0]
    .chirp_is_down    ( 1'b0         ), // input
    .chirp_delay      ( 4'b11        ), // input [3:0]
    .chirp_min_ctrl   ( 32'h24E9     ), // input [31:0]
    .chirp_max_ctrl   ( 32'h49D2     ), // input [31:0]
    .chirp_inc_rate   ( 32'h554      ), // input [31:0]
    .chirp_div_rate   ( 32'h1606D3   ), // input [31:0]
    .pulse_duty_cycle ( 32'h3FFFFFFF ), // input [31:0]
    .wave_out         ( message      )  // output [7:0]
//  .wave2_out        (              )  // output [7:0]
);

FMModulator FMModulator0 (
    .clk       ( CLK_100M  ), // input
    .message   ( message   ), // input [7:0]
    .ctr_ctrl  ( 32'h1F751 ), // input [31:0]
    .deviation ( 5'b01000  ), // input [4:0]
    .modulated ( modulated )  // output [7:0]
);

FMDemodulator FMDemodulator0 (
    .clk         ( CLK_100M    ), // input
    .modulated   ( modulated   ), // input [7:0]
    .ctr_ctrl    ( 32'h1F751   ), // input [31:0]
    .demodulated ( demodulated )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( to_audio ), // input [3:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
