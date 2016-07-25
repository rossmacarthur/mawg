module Audio (
    input clk,
    input [7:0] value, // the input amplitude
    output reg AUD_PWM // the pin to PWM
);

reg [7:0] count;

always @(posedge clk) begin
    count <= count + 1'b1;
    AUD_PWM <= (value < count) ? 1'bz : 1'b0;
end

endmodule
