module Sawtooth (
    input clk,
    input [31:0] control,
    output reg [7:0] amplitude
);

reg [31:0] phase;

always @(posedge clk) begin
    phase <= phase + control;
    amplitude <= phase[31:24]; 
end

endmodule
