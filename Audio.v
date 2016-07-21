module Audio(
    input clk,
    input [7:0] value,
    output reg AUD_PWM
);

reg [7:0] count;

always @(posedge clk) begin
    count <= count + 1'b1;
    AUD_PWM <= (value < count) ? 1'bz : 1'b0;
end

endmodule
