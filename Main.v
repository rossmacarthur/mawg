module Main (
    input CLK,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1,
    output SYNC,
    output DATA,
    output SCLK
);

wire CLK_100M;
wire CLK_50M;
wire CLK_75M;
wire CLK_85M;

wire [7:0] sin_out;
wire [11:0] signal;
wire [31:0] control;

assign control = SW[15:5] << SW[4:0];
assign signal = {~sin_out[7], sin_out[6:0]} << 4;

// Connect up modules
Clock_Generator Clock_Gen (
    .CLK_IN1  ( CLK      ), // input
    .CLK_OUT1 ( CLK_100M ), // output
    .CLK_OUT2 ( CLK_50M  ), // output
	 .CLK_OUT3 ( CLK_75M  ), // output
	 .CLK_OUT4 ( CLK_85M  )  // output
);

NCO NCO0 (
    .clk     ( CLK_100M ), // input
    .rst     ( 1'b0     ), // input
    .ctrl    ( control  ), // input [31:0]
    .sin_out ( sin_out  )  // output [7:0]
  //.cos_out ( cos_out  )
);

PmodDA4_Control PmodDA4_Control0 (
    .clk     ( CLK_75M ), // input
	 .rst     ( 1'b0    ), // input
	 .signal  ( signal  ), // input [11:0]
	 .SYNC    ( SYNC    ), // output
	 .DATA    ( DATA    ), // output
	 .SCLK    ( SCLK    )  // output
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( sin_out  ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
