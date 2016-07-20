module Main(
    input CLK_100M,
    output AUD_PWM,
    output reg LED,
    output reg AUD_SD=1'b1
);

// Create a square wave of frequency 500 Hz
reg [10:0] value;
reg [17:0] count;
always @(posedge CLK_100M) begin
    count <= count + 1'b1;
    LED <= count < 18'h1FFFF ? 1'b1 : 1'b0;
    value <= count < 18'h1FFFF ? 11'h400 : 18'h0;
end

// Connect up modules
Audio AudioJack(
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [11:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
