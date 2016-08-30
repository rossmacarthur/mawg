module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire reset;
wire [7:0] value;
wire [31:0] control;

// Connect up modules
Chirp Chirp0 (
    .clk        ( CLK_100M  ), // input
    .delay      ( 4'b10     ), // input [3:0]
    .down_chirp ( SW[15]    ), // input
    .min_ctrl   ( 32'h49D2  ), // input [31:0]
    .max_ctrl   ( 32'h49D1E ), // input [31:0]
    .prp_rate   ( 16'hB5    ), // input [15:0]
    .inv_rate   ( {1'b1, SW[14:0]}  ), // input [15:0]
    .nco_reset  ( reset     ), // output
    .nco_ctrl   ( control   )  // output [31:0]
);

NCO NCO0 (
    .clk       ( CLK_100M ), // input
    .reset     ( reset    ), // input
    .control   ( control  ), // input [31:0]
    .amplitude ( value    )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
