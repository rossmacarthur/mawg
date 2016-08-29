module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;

// Connect up modules
NCO NCO0 (
    .clk       ( CLK_100M  ), // input
    .reset     ( 1'b0      ), // input
    .control   ( SW        ), // input [15:0]
    .amplitude ( value     )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
