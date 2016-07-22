// Phase-to-amplitude converter for sine wave
module PAC(
    input [7:0] phase,
    output reg [7:0] amplitude
);

reg [5:0] selector;
reg [7:0] value;

always @(*) begin
    if (phase[6]) selector <= |phase[5:0] ? ~(phase[5:0]-1) : 6'h3F;
    else          selector <= phase[5:0];
    amplitude <= phase[7] ? ~value : value;
    case(selector)
        6'h00 : value <= 8'h80;
        6'h01 : value <= 8'h83;
        6'h02 : value <= 8'h86;
        6'h03 : value <= 8'h89;
        6'h04 : value <= 8'h8C;
        6'h05 : value <= 8'h8F;
        6'h06 : value <= 8'h92;
        6'h07 : value <= 8'h95;
        6'h08 : value <= 8'h98;
        6'h09 : value <= 8'h9B;
        6'h0A : value <= 8'h9E;
        6'h0B : value <= 8'hA2;
        6'h0C : value <= 8'hA5;
        6'h0D : value <= 8'hA7;
        6'h0E : value <= 8'hAA;
        6'h0F : value <= 8'hAD;
        6'h10 : value <= 8'hB0;
        6'h11 : value <= 8'hB3;
        6'h12 : value <= 8'hB6;
        6'h13 : value <= 8'hB9;
        6'h14 : value <= 8'hBC;
        6'h15 : value <= 8'hBE;
        6'h16 : value <= 8'hC1;
        6'h17 : value <= 8'hC4;
        6'h18 : value <= 8'hC6;
        6'h19 : value <= 8'hC9;
        6'h1A : value <= 8'hCB;
        6'h1B : value <= 8'hCE;
        6'h1C : value <= 8'hD0;
        6'h1D : value <= 8'hD3;
        6'h1E : value <= 8'hD5;
        6'h1F : value <= 8'hD7;
        6'h20 : value <= 8'hDA;
        6'h21 : value <= 8'hDC;
        6'h22 : value <= 8'hDE;
        6'h23 : value <= 8'hE0;
        6'h24 : value <= 8'hE2;
        6'h25 : value <= 8'hE4;
        6'h26 : value <= 8'hE6;
        6'h27 : value <= 8'hE8;
        6'h28 : value <= 8'hEA;
        6'h29 : value <= 8'hEB;
        6'h2A : value <= 8'hED;
        6'h2B : value <= 8'hEE;
        6'h2C : value <= 8'hF0;
        6'h2D : value <= 8'hF1;
        6'h2E : value <= 8'hF3;
        6'h2F : value <= 8'hF4;
        6'h30 : value <= 8'hF5;
        6'h31 : value <= 8'hF6;
        6'h32 : value <= 8'hF8;
        6'h33 : value <= 8'hF9;
        6'h34 : value <= 8'hFA;
        6'h35 : value <= 8'hFA;
        6'h36 : value <= 8'hFB;
        6'h37 : value <= 8'hFC;
        6'h38 : value <= 8'hFD;
        6'h39 : value <= 8'hFD;
        6'h3A : value <= 8'hFE;
        6'h3B : value <= 8'hFE;
        6'h3C : value <= 8'hFE;
        6'h3D : value <= 8'hFF;
        6'h3E : value <= 8'hFF;
        6'h3F : value <= 8'hFF;
    endcase
end

endmodule
