module Chirp (
    input clk,
    input [3:0] delay,
    input down_chirp,
    input [31:0] min_ctrl,
    input [31:0] max_ctrl,
    input [15:0] prp_rate,
    input [15:0] inv_rate,
    output reg nco_reset,
    output reg [31:0] nco_ctrl
);

reg [3:0] delay_count;
reg [15:0] rate_count;
reg [31:0] start_ctrl;
reg [31:0] end_ctrl;
reg end_reached;

always @(posedge clk) begin
    start_ctrl <= down_chirp ? max_ctrl : min_ctrl;
    end_ctrl <= down_chirp ? min_ctrl : max_ctrl;
    end_reached <= down_chirp ? (nco_ctrl <= end_ctrl) : (nco_ctrl >= end_ctrl);
    
    if (end_reached) begin
        nco_ctrl <= start_ctrl;
        if (delay_count >= delay) begin
            nco_reset <= 1'b0;
            delay_count <= delay;
        end else begin
            nco_reset <= 1'b1;
            delay_count <= delay_count + 1'b1;
        end
    end else if (rate_count >= inv_rate) begin
        rate_count <= 16'h0;
        nco_ctrl <= down_chirp ? nco_ctrl - prp_rate : nco_ctrl + prp_rate;
    end else
        rate_count <= rate_count + 1'b1;

end

endmodule
