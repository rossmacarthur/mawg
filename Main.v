module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;

// Connect up modules
Pulse Pulse0 (
    .clk   ( CLK_100M     ), // input
    .ctrl  ( 32'b1111110000000 ),
    .duty  ( {SW, 16'hFF} ),
    .amplitude ( value )
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
