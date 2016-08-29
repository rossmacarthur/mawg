// Clock divided full LUT NCO (sine output only)
// Author: Ross MacArthur
//   16-bit input control word
//   8-bit signed output amplitude
//   frequency = clk / (control * 256)

module NCO (
    input clk,
    input reset,
    input [15:0] control,       // frequency control word
    output reg [7:0] amplitude // signed output amplitude of wave
);

// Clock Divider and Phase Accumulator
reg [15:0] count;   // to divide clock down to sample freq
reg [7:0] phase;    // current position in period

always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        phase <= 0;
    end else if (count == control) begin
        count <= 1'b0;
        phase <= phase + 1'b1;
    end else
        count <= count + 1'b1;
end

// Full Sine Look-up Table
always @(*) begin
    case(phase)
        8'h00 : amplitude <= 8'h80;
        8'h01 : amplitude <= 8'h83;
        8'h02 : amplitude <= 8'h86;
        8'h03 : amplitude <= 8'h89;
        8'h04 : amplitude <= 8'h8C;
        8'h05 : amplitude <= 8'h8F;
        8'h06 : amplitude <= 8'h92;
        8'h07 : amplitude <= 8'h95;
        8'h08 : amplitude <= 8'h98;
        8'h09 : amplitude <= 8'h9B;
        8'h0A : amplitude <= 8'h9E;
        8'h0B : amplitude <= 8'hA2;
        8'h0C : amplitude <= 8'hA5;
        8'h0D : amplitude <= 8'hA7;
        8'h0E : amplitude <= 8'hAA;
        8'h0F : amplitude <= 8'hAD;
        8'h10 : amplitude <= 8'hB0;
        8'h11 : amplitude <= 8'hB3;
        8'h12 : amplitude <= 8'hB6;
        8'h13 : amplitude <= 8'hB9;
        8'h14 : amplitude <= 8'hBC;
        8'h15 : amplitude <= 8'hBE;
        8'h16 : amplitude <= 8'hC1;
        8'h17 : amplitude <= 8'hC4;
        8'h18 : amplitude <= 8'hC6;
        8'h19 : amplitude <= 8'hC9;
        8'h1A : amplitude <= 8'hCB;
        8'h1B : amplitude <= 8'hCE;
        8'h1C : amplitude <= 8'hD0;
        8'h1D : amplitude <= 8'hD3;
        8'h1E : amplitude <= 8'hD5;
        8'h1F : amplitude <= 8'hD7;
        8'h20 : amplitude <= 8'hDA;
        8'h21 : amplitude <= 8'hDC;
        8'h22 : amplitude <= 8'hDE;
        8'h23 : amplitude <= 8'hE0;
        8'h24 : amplitude <= 8'hE2;
        8'h25 : amplitude <= 8'hE4;
        8'h26 : amplitude <= 8'hE6;
        8'h27 : amplitude <= 8'hE8;
        8'h28 : amplitude <= 8'hEA;
        8'h29 : amplitude <= 8'hEB;
        8'h2A : amplitude <= 8'hED;
        8'h2B : amplitude <= 8'hEE;
        8'h2C : amplitude <= 8'hF0;
        8'h2D : amplitude <= 8'hF1;
        8'h2E : amplitude <= 8'hF3;
        8'h2F : amplitude <= 8'hF4;
        8'h30 : amplitude <= 8'hF5;
        8'h31 : amplitude <= 8'hF6;
        8'h32 : amplitude <= 8'hF8;
        8'h33 : amplitude <= 8'hF9;
        8'h34 : amplitude <= 8'hFA;
        8'h35 : amplitude <= 8'hFA;
        8'h36 : amplitude <= 8'hFB;
        8'h37 : amplitude <= 8'hFC;
        8'h38 : amplitude <= 8'hFD;
        8'h39 : amplitude <= 8'hFD;
        8'h3A : amplitude <= 8'hFE;
        8'h3B : amplitude <= 8'hFE;
        8'h3C : amplitude <= 8'hFE;
        8'h3D : amplitude <= 8'hFF;
        8'h3E : amplitude <= 8'hFF;
        8'h3F : amplitude <= 8'hFF;
        8'h40 : amplitude <= 8'hFF;
        8'h41 : amplitude <= 8'hFF;
        8'h42 : amplitude <= 8'hFF;
        8'h43 : amplitude <= 8'hFF;
        8'h44 : amplitude <= 8'hFE;
        8'h45 : amplitude <= 8'hFE;
        8'h46 : amplitude <= 8'hFE;
        8'h47 : amplitude <= 8'hFD;
        8'h48 : amplitude <= 8'hFD;
        8'h49 : amplitude <= 8'hFC;
        8'h4A : amplitude <= 8'hFB;
        8'h4B : amplitude <= 8'hFA;
        8'h4C : amplitude <= 8'hFA;
        8'h4D : amplitude <= 8'hF9;
        8'h4E : amplitude <= 8'hF8;
        8'h4F : amplitude <= 8'hF6;
        8'h50 : amplitude <= 8'hF5;
        8'h51 : amplitude <= 8'hF4;
        8'h52 : amplitude <= 8'hF3;
        8'h53 : amplitude <= 8'hF1;
        8'h54 : amplitude <= 8'hF0;
        8'h55 : amplitude <= 8'hEE;
        8'h56 : amplitude <= 8'hED;
        8'h57 : amplitude <= 8'hEB;
        8'h58 : amplitude <= 8'hEA;
        8'h59 : amplitude <= 8'hE8;
        8'h5A : amplitude <= 8'hE6;
        8'h5B : amplitude <= 8'hE4;
        8'h5C : amplitude <= 8'hE2;
        8'h5D : amplitude <= 8'hE0;
        8'h5E : amplitude <= 8'hDE;
        8'h5F : amplitude <= 8'hDC;
        8'h60 : amplitude <= 8'hDA;
        8'h61 : amplitude <= 8'hD7;
        8'h62 : amplitude <= 8'hD5;
        8'h63 : amplitude <= 8'hD3;
        8'h64 : amplitude <= 8'hD0;
        8'h65 : amplitude <= 8'hCE;
        8'h66 : amplitude <= 8'hCB;
        8'h67 : amplitude <= 8'hC9;
        8'h68 : amplitude <= 8'hC6;
        8'h69 : amplitude <= 8'hC4;
        8'h6A : amplitude <= 8'hC1;
        8'h6B : amplitude <= 8'hBE;
        8'h6C : amplitude <= 8'hBC;
        8'h6D : amplitude <= 8'hB9;
        8'h6E : amplitude <= 8'hB6;
        8'h6F : amplitude <= 8'hB3;
        8'h70 : amplitude <= 8'hB0;
        8'h71 : amplitude <= 8'hAD;
        8'h72 : amplitude <= 8'hAA;
        8'h73 : amplitude <= 8'hA7;
        8'h74 : amplitude <= 8'hA5;
        8'h75 : amplitude <= 8'hA2;
        8'h76 : amplitude <= 8'h9E;
        8'h77 : amplitude <= 8'h9B;
        8'h78 : amplitude <= 8'h98;
        8'h79 : amplitude <= 8'h95;
        8'h7A : amplitude <= 8'h92;
        8'h7B : amplitude <= 8'h8F;
        8'h7C : amplitude <= 8'h8C;
        8'h7D : amplitude <= 8'h89;
        8'h7E : amplitude <= 8'h86;
        8'h7F : amplitude <= 8'h83;
        8'h80 : amplitude <= 8'h80;
        8'h81 : amplitude <= 8'h7C;
        8'h82 : amplitude <= 8'h79;
        8'h83 : amplitude <= 8'h76;
        8'h84 : amplitude <= 8'h73;
        8'h85 : amplitude <= 8'h70;
        8'h86 : amplitude <= 8'h6D;
        8'h87 : amplitude <= 8'h6A;
        8'h88 : amplitude <= 8'h67;
        8'h89 : amplitude <= 8'h64;
        8'h8A : amplitude <= 8'h61;
        8'h8B : amplitude <= 8'h5D;
        8'h8C : amplitude <= 8'h5A;
        8'h8D : amplitude <= 8'h58;
        8'h8E : amplitude <= 8'h55;
        8'h8F : amplitude <= 8'h52;
        8'h90 : amplitude <= 8'h4F;
        8'h91 : amplitude <= 8'h4C;
        8'h92 : amplitude <= 8'h49;
        8'h93 : amplitude <= 8'h46;
        8'h94 : amplitude <= 8'h43;
        8'h95 : amplitude <= 8'h41;
        8'h96 : amplitude <= 8'h3E;
        8'h97 : amplitude <= 8'h3B;
        8'h98 : amplitude <= 8'h39;
        8'h99 : amplitude <= 8'h36;
        8'h9A : amplitude <= 8'h34;
        8'h9B : amplitude <= 8'h31;
        8'h9C : amplitude <= 8'h2F;
        8'h9D : amplitude <= 8'h2C;
        8'h9E : amplitude <= 8'h2A;
        8'h9F : amplitude <= 8'h28;
        8'hA0 : amplitude <= 8'h25;
        8'hA1 : amplitude <= 8'h23;
        8'hA2 : amplitude <= 8'h21;
        8'hA3 : amplitude <= 8'h1F;
        8'hA4 : amplitude <= 8'h1D;
        8'hA5 : amplitude <= 8'h1B;
        8'hA6 : amplitude <= 8'h19;
        8'hA7 : amplitude <= 8'h17;
        8'hA8 : amplitude <= 8'h15;
        8'hA9 : amplitude <= 8'h14;
        8'hAA : amplitude <= 8'h12;
        8'hAB : amplitude <= 8'h11;
        8'hAC : amplitude <= 8'h0F;
        8'hAD : amplitude <= 8'h0E;
        8'hAE : amplitude <= 8'h0C;
        8'hAF : amplitude <= 8'h0B;
        8'hB0 : amplitude <= 8'h0A;
        8'hB1 : amplitude <= 8'h09;
        8'hB2 : amplitude <= 8'h07;
        8'hB3 : amplitude <= 8'h06;
        8'hB4 : amplitude <= 8'h05;
        8'hB5 : amplitude <= 8'h05;
        8'hB6 : amplitude <= 8'h04;
        8'hB7 : amplitude <= 8'h03;
        8'hB8 : amplitude <= 8'h02;
        8'hB9 : amplitude <= 8'h02;
        8'hBA : amplitude <= 8'h01;
        8'hBB : amplitude <= 8'h01;
        8'hBC : amplitude <= 8'h01;
        8'hBD : amplitude <= 8'h00;
        8'hBE : amplitude <= 8'h00;
        8'hBF : amplitude <= 8'h00;
        8'hC0 : amplitude <= 8'h00;
        8'hC1 : amplitude <= 8'h00;
        8'hC2 : amplitude <= 8'h00;
        8'hC3 : amplitude <= 8'h00;
        8'hC4 : amplitude <= 8'h01;
        8'hC5 : amplitude <= 8'h01;
        8'hC6 : amplitude <= 8'h01;
        8'hC7 : amplitude <= 8'h02;
        8'hC8 : amplitude <= 8'h02;
        8'hC9 : amplitude <= 8'h03;
        8'hCA : amplitude <= 8'h04;
        8'hCB : amplitude <= 8'h05;
        8'hCC : amplitude <= 8'h05;
        8'hCD : amplitude <= 8'h06;
        8'hCE : amplitude <= 8'h07;
        8'hCF : amplitude <= 8'h09;
        8'hD0 : amplitude <= 8'h0A;
        8'hD1 : amplitude <= 8'h0B;
        8'hD2 : amplitude <= 8'h0C;
        8'hD3 : amplitude <= 8'h0E;
        8'hD4 : amplitude <= 8'h0F;
        8'hD5 : amplitude <= 8'h11;
        8'hD6 : amplitude <= 8'h12;
        8'hD7 : amplitude <= 8'h14;
        8'hD8 : amplitude <= 8'h15;
        8'hD9 : amplitude <= 8'h17;
        8'hDA : amplitude <= 8'h19;
        8'hDB : amplitude <= 8'h1B;
        8'hDC : amplitude <= 8'h1D;
        8'hDD : amplitude <= 8'h1F;
        8'hDE : amplitude <= 8'h21;
        8'hDF : amplitude <= 8'h23;
        8'hE0 : amplitude <= 8'h25;
        8'hE1 : amplitude <= 8'h28;
        8'hE2 : amplitude <= 8'h2A;
        8'hE3 : amplitude <= 8'h2C;
        8'hE4 : amplitude <= 8'h2F;
        8'hE5 : amplitude <= 8'h31;
        8'hE6 : amplitude <= 8'h34;
        8'hE7 : amplitude <= 8'h36;
        8'hE8 : amplitude <= 8'h39;
        8'hE9 : amplitude <= 8'h3B;
        8'hEA : amplitude <= 8'h3E;
        8'hEB : amplitude <= 8'h41;
        8'hEC : amplitude <= 8'h43;
        8'hED : amplitude <= 8'h46;
        8'hEE : amplitude <= 8'h49;
        8'hEF : amplitude <= 8'h4C;
        8'hF0 : amplitude <= 8'h4F;
        8'hF1 : amplitude <= 8'h52;
        8'hF2 : amplitude <= 8'h55;
        8'hF3 : amplitude <= 8'h58;
        8'hF4 : amplitude <= 8'h5A;
        8'hF5 : amplitude <= 8'h5D;
        8'hF6 : amplitude <= 8'h61;
        8'hF7 : amplitude <= 8'h64;
        8'hF8 : amplitude <= 8'h67;
        8'hF9 : amplitude <= 8'h6A;
        8'hFA : amplitude <= 8'h6D;
        8'hFB : amplitude <= 8'h70;
        8'hFC : amplitude <= 8'h73;
        8'hFD : amplitude <= 8'h76;
        8'hFE : amplitude <= 8'h79;
        8'hFF : amplitude <= 8'h7C;
    endcase
end

endmodule
