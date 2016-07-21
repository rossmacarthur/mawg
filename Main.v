module Main(
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

// Count phase for sine wave
wire [7:0] value;
reg [7:0] phase;
reg [15:0] count;
always @(posedge CLK_100M) begin
    if (count == SW) begin
        count <= 1'b0;
        phase <= phase + 1'b1;
    end else
        count <= count + 1'b1;
end

// Connect up modules
Audio Audio0(
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

PAC PAC0 (
    .phase     ( phase ), // input [7:0]
    .amplitude ( value )  // output [7:0]
);

endmodule
