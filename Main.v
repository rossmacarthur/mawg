module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;
wire [31:0] control;

assign control = SW[15:4] << SW[3:0];

Sawtooth Sawtooth0 (
    .clk       ( CLK_100M ), // input
    .control   ( control  ), // input [31:0]
    .amplitude ( value    )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
