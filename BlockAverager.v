module BlockAverager (
    input clk,
    input [31:0] phase,        // current phase of center frequency signal
    input [7:0] signal,        // signed amplitude of signal
    output reg [7:0] filtered  // signed amplitude of filtered wave
);

reg prev_phase;
reg [15:0] buff [63:0];
reg [21:0] sum;

integer i;
always @(posedge clk) begin
    if (phase[27] ^ prev_phase) begin
        prev_phase <= phase[27];
        buff[0] <= {{8{signal[7]}}, signal};
        for (i = 63; i > 0; i=i-1) begin
            buff[i] <= buff[i-1];
        end 
        sum<= buff[0] + buff[1] + buff[2] + buff[3] + 
              buff[4] + buff[5] + buff[6] + buff[7] + 
              buff[8] + buff[9] + buff[10] + buff[11] + 
              buff[12] + buff[13] + buff[14] + buff[15] +
              buff[16] + buff[17] + buff[18] + buff[19] + 
              buff[20] + buff[21] + buff[22] + buff[23] + 
              buff[24] + buff[25] + buff[26] + buff[27] + 
              buff[28] + buff[29] + buff[30] + buff[31] +
              buff[32] + buff[33] + buff[34] + buff[35] + 
              buff[36] + buff[37] + buff[38] + buff[39] + 
              buff[40] + buff[41] + buff[42] + buff[43] + 
              buff[44] + buff[45] + buff[46] + buff[47] +
              buff[48] + buff[49] + buff[50] + buff[51] +
              buff[52] + buff[53] + buff[54] + buff[55] +
              buff[56] + buff[57] + buff[58] + buff[59] +
              buff[60] + buff[61] + buff[62] + buff[63];
        filtered <= {sum >>> 6}[7:0];
    end
end

endmodule
