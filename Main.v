module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;
wire [7:0] svalue;
wire [7:0] cvalue;
wire [31:0] control;
assign value = (SW[15] ? svalue : cvalue);
assign control = SW[14:4] << SW[3:0];

// Connect up modules
NCO NCO0 (
    .clk     ( CLK_100M ), // input
    .reset   ( 1'b0     ), // input
    .ctrl    ( control  ), // input [15:0]
    .sin_out ( svalue   ), // output [7:0]
    .cos_out ( cvalue   )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
