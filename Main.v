module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;
wire [31:0] control;
assign control = SW[13:4] << SW[3:0];

// Connect up modules
WaveGenerator WaveGenerator0 (
    .clk              ( CLK_100M     ), // input
    .wave_sel         ( SW[15:14]    ), // input [1:0]
    .freq_ctrl        ( 32'h49D2     ), // input [31:0]
    .chirp_is_down    ( SW[13]       ), // input
    .chirp_delay      ( SW[3:0]      ), // input [3:0]
    .chirp_min_ctrl   ( 32'h10C7     ), // input [31:0]
    .chirp_max_ctrl   ( 32'h68DB9    ), // input [31:0]
    .chirp_inc_rate   ( 32'h355      ), // input [31:0]
    .chirp_div_rate   ( 32'hB7AA18   ), // input [31:0]
    .pulse_duty_cycle ( 32'h3FFFFFFF ), // input [31:0]
    .wave_out         ( value        )  // output [7:0]
//  .wave2_out        (              )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
