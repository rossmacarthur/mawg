module Pulse (
    input clk,
    input [31:0] ctrl,
    input [31:0] duty,
    output reg [7:0] amplitude
);

reg [31:0] count;

always @(posedge clk) begin
    count <= count + ctrl;
    amplitude <= (count < duty) ? 8'hFF : 8'h00;
end

endmodule
