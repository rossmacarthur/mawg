module Chirp (
    input clk,
    input [3:0] delay,
    input [15:0] prp_rate,
    input [15:0] inv_rate,
    input [31:0] start_ctrl,
    input [31:0] end_ctrl,
    output reg nco_reset,
    output reg [31:0] nco_control
);

reg [3:0] delay_count;
reg [15:0] rate_count;
always @(posedge clk) begin
    if (nco_control >= end_ctrl) begin
        if (delay_count >= delay) begin
            nco_reset <= 1'b0;
            delay_count <= 4'b0;
        end else begin
            nco_reset <= 1'b1;
            delay_count <= delay_count + 1'b1;
        end
        nco_control <= start_ctrl;
    end else if (rate_count == inv_rate) begin
        rate_count <= 16'h0;
        nco_control <= nco_control + prp_rate;
    end else 
        rate_count <= rate_count + 1'b1;
end

endmodule
