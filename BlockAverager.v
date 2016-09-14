module BlockAverager (
    input clk,
    input [31:0] phase,
    input [7:0] signal,
    output reg [7:0] filtered
);

reg prev_phase;
reg [15:0] buff [15:0];
reg [11:0] sum;

integer i;
always @(posedge clk) begin
    if (phase[29] ^ prev_phase) begin
        prev_phase <= phase[29];

        buff[0] <= {{8{signal[7]}}, signal};
        for (i = 15; i > 0; i=i-1) begin
            buff[i] <= buff[i-1];
        end

        sum <= buff[0] + buff[1] + buff[2] + buff[3] +
               buff[4] + buff[5] + buff[6] + buff[7] +
               buff[8] + buff[9] + buff[10] + buff[11] +
               buff[12] + buff[13] + buff[14] + buff[15];
        filtered <= {sum >>> 4}[7:0];
    end
end


endmodule
