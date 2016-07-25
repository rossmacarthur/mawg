module NCO (
    input clk,
    input reset,
    input [15:0] control,      // frequency control word
    output reg [7:0] amplitude // output amplitude of wave
);

parameter S = 10; // 2**S samples (need to generate new LUP to change this)

// Phase Accumulator
reg [15:0] count;   // to divide clock down to sample freq
reg [S-1:0] phase;  // current position in period
reg [S-3:0] select; // based on phase to pick amplitude value
reg [7:0] value;    // positive amplitude value

always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        phase <= 0;
    end else if (count == control) begin
        count <= 1'b0;
        phase <= phase + 1'b1;
    end else
        count <= count + 1'b1;

    // To deal with only Quarter Sine LUP
    select <= phase[S-2] ? (|phase[S-3:0] ? ~(phase[S-3:0]-1'b1) : {(S-2){1'b1}}) : phase[S-3:0];
    amplitude <= phase[S-1] ? ~value : value;
end

// Quarter Sine Look-up Table
always @(*) begin
    case(select)
        8'h00 : value <= 8'h80;
        8'h01 : value <= 8'h80;
        8'h02 : value <= 8'h81;
        8'h03 : value <= 8'h82;
        8'h04 : value <= 8'h83;
        8'h05 : value <= 8'h83;
        8'h06 : value <= 8'h84;
        8'h07 : value <= 8'h85;
        8'h08 : value <= 8'h86;
        8'h09 : value <= 8'h87;
        8'h0A : value <= 8'h87;
        8'h0B : value <= 8'h88;
        8'h0C : value <= 8'h89;
        8'h0D : value <= 8'h8A;
        8'h0E : value <= 8'h8A;
        8'h0F : value <= 8'h8B;
        8'h10 : value <= 8'h8C;
        8'h11 : value <= 8'h8D;
        8'h12 : value <= 8'h8E;
        8'h13 : value <= 8'h8E;
        8'h14 : value <= 8'h8F;
        8'h15 : value <= 8'h90;
        8'h16 : value <= 8'h91;
        8'h17 : value <= 8'h91;
        8'h18 : value <= 8'h92;
        8'h19 : value <= 8'h93;
        8'h1A : value <= 8'h94;
        8'h1B : value <= 8'h95;
        8'h1C : value <= 8'h95;
        8'h1D : value <= 8'h96;
        8'h1E : value <= 8'h97;
        8'h1F : value <= 8'h98;
        8'h20 : value <= 8'h98;
        8'h21 : value <= 8'h99;
        8'h22 : value <= 8'h9A;
        8'h23 : value <= 8'h9B;
        8'h24 : value <= 8'h9B;
        8'h25 : value <= 8'h9C;
        8'h26 : value <= 8'h9D;
        8'h27 : value <= 8'h9E;
        8'h28 : value <= 8'h9E;
        8'h29 : value <= 8'h9F;
        8'h2A : value <= 8'hA0;
        8'h2B : value <= 8'hA1;
        8'h2C : value <= 8'hA2;
        8'h2D : value <= 8'hA2;
        8'h2E : value <= 8'hA3;
        8'h2F : value <= 8'hA4;
        8'h30 : value <= 8'hA5;
        8'h31 : value <= 8'hA5;
        8'h32 : value <= 8'hA6;
        8'h33 : value <= 8'hA7;
        8'h34 : value <= 8'hA7;
        8'h35 : value <= 8'hA8;
        8'h36 : value <= 8'hA9;
        8'h37 : value <= 8'hAA;
        8'h38 : value <= 8'hAA;
        8'h39 : value <= 8'hAB;
        8'h3A : value <= 8'hAC;
        8'h3B : value <= 8'hAD;
        8'h3C : value <= 8'hAD;
        8'h3D : value <= 8'hAE;
        8'h3E : value <= 8'hAF;
        8'h3F : value <= 8'hB0;
        8'h40 : value <= 8'hB0;
        8'h41 : value <= 8'hB1;
        8'h42 : value <= 8'hB2;
        8'h43 : value <= 8'hB2;
        8'h44 : value <= 8'hB3;
        8'h45 : value <= 8'hB4;
        8'h46 : value <= 8'hB5;
        8'h47 : value <= 8'hB5;
        8'h48 : value <= 8'hB6;
        8'h49 : value <= 8'hB7;
        8'h4A : value <= 8'hB7;
        8'h4B : value <= 8'hB8;
        8'h4C : value <= 8'hB9;
        8'h4D : value <= 8'hBA;
        8'h4E : value <= 8'hBA;
        8'h4F : value <= 8'hBB;
        8'h50 : value <= 8'hBC;
        8'h51 : value <= 8'hBC;
        8'h52 : value <= 8'hBD;
        8'h53 : value <= 8'hBE;
        8'h54 : value <= 8'hBE;
        8'h55 : value <= 8'hBF;
        8'h56 : value <= 8'hC0;
        8'h57 : value <= 8'hC0;
        8'h58 : value <= 8'hC1;
        8'h59 : value <= 8'hC2;
        8'h5A : value <= 8'hC2;
        8'h5B : value <= 8'hC3;
        8'h5C : value <= 8'hC4;
        8'h5D : value <= 8'hC4;
        8'h5E : value <= 8'hC5;
        8'h5F : value <= 8'hC6;
        8'h60 : value <= 8'hC6;
        8'h61 : value <= 8'hC7;
        8'h62 : value <= 8'hC8;
        8'h63 : value <= 8'hC8;
        8'h64 : value <= 8'hC9;
        8'h65 : value <= 8'hCA;
        8'h66 : value <= 8'hCA;
        8'h67 : value <= 8'hCB;
        8'h68 : value <= 8'hCB;
        8'h69 : value <= 8'hCC;
        8'h6A : value <= 8'hCD;
        8'h6B : value <= 8'hCD;
        8'h6C : value <= 8'hCE;
        8'h6D : value <= 8'hCF;
        8'h6E : value <= 8'hCF;
        8'h6F : value <= 8'hD0;
        8'h70 : value <= 8'hD0;
        8'h71 : value <= 8'hD1;
        8'h72 : value <= 8'hD2;
        8'h73 : value <= 8'hD2;
        8'h74 : value <= 8'hD3;
        8'h75 : value <= 8'hD3;
        8'h76 : value <= 8'hD4;
        8'h77 : value <= 8'hD5;
        8'h78 : value <= 8'hD5;
        8'h79 : value <= 8'hD6;
        8'h7A : value <= 8'hD6;
        8'h7B : value <= 8'hD7;
        8'h7C : value <= 8'hD7;
        8'h7D : value <= 8'hD8;
        8'h7E : value <= 8'hD9;
        8'h7F : value <= 8'hD9;
        8'h80 : value <= 8'hDA;
        8'h81 : value <= 8'hDA;
        8'h82 : value <= 8'hDB;
        8'h83 : value <= 8'hDB;
        8'h84 : value <= 8'hDC;
        8'h85 : value <= 8'hDC;
        8'h86 : value <= 8'hDD;
        8'h87 : value <= 8'hDD;
        8'h88 : value <= 8'hDE;
        8'h89 : value <= 8'hDE;
        8'h8A : value <= 8'hDF;
        8'h8B : value <= 8'hE0;
        8'h8C : value <= 8'hE0;
        8'h8D : value <= 8'hE1;
        8'h8E : value <= 8'hE1;
        8'h8F : value <= 8'hE2;
        8'h90 : value <= 8'hE2;
        8'h91 : value <= 8'hE3;
        8'h92 : value <= 8'hE3;
        8'h93 : value <= 8'hE4;
        8'h94 : value <= 8'hE4;
        8'h95 : value <= 8'hE4;
        8'h96 : value <= 8'hE5;
        8'h97 : value <= 8'hE5;
        8'h98 : value <= 8'hE6;
        8'h99 : value <= 8'hE6;
        8'h9A : value <= 8'hE7;
        8'h9B : value <= 8'hE7;
        8'h9C : value <= 8'hE8;
        8'h9D : value <= 8'hE8;
        8'h9E : value <= 8'hE9;
        8'h9F : value <= 8'hE9;
        8'hA0 : value <= 8'hEA;
        8'hA1 : value <= 8'hEA;
        8'hA2 : value <= 8'hEA;
        8'hA3 : value <= 8'hEB;
        8'hA4 : value <= 8'hEB;
        8'hA5 : value <= 8'hEC;
        8'hA6 : value <= 8'hEC;
        8'hA7 : value <= 8'hEC;
        8'hA8 : value <= 8'hED;
        8'hA9 : value <= 8'hED;
        8'hAA : value <= 8'hEE;
        8'hAB : value <= 8'hEE;
        8'hAC : value <= 8'hEE;
        8'hAD : value <= 8'hEF;
        8'hAE : value <= 8'hEF;
        8'hAF : value <= 8'hF0;
        8'hB0 : value <= 8'hF0;
        8'hB1 : value <= 8'hF0;
        8'hB2 : value <= 8'hF1;
        8'hB3 : value <= 8'hF1;
        8'hB4 : value <= 8'hF1;
        8'hB5 : value <= 8'hF2;
        8'hB6 : value <= 8'hF2;
        8'hB7 : value <= 8'hF2;
        8'hB8 : value <= 8'hF3;
        8'hB9 : value <= 8'hF3;
        8'hBA : value <= 8'hF3;
        8'hBB : value <= 8'hF4;
        8'hBC : value <= 8'hF4;
        8'hBD : value <= 8'hF4;
        8'hBE : value <= 8'hF5;
        8'hBF : value <= 8'hF5;
        8'hC0 : value <= 8'hF5;
        8'hC1 : value <= 8'hF6;
        8'hC2 : value <= 8'hF6;
        8'hC3 : value <= 8'hF6;
        8'hC4 : value <= 8'hF6;
        8'hC5 : value <= 8'hF7;
        8'hC6 : value <= 8'hF7;
        8'hC7 : value <= 8'hF7;
        8'hC8 : value <= 8'hF8;
        8'hC9 : value <= 8'hF8;
        8'hCA : value <= 8'hF8;
        8'hCB : value <= 8'hF8;
        8'hCC : value <= 8'hF9;
        8'hCD : value <= 8'hF9;
        8'hCE : value <= 8'hF9;
        8'hCF : value <= 8'hF9;
        8'hD0 : value <= 8'hFA;
        8'hD1 : value <= 8'hFA;
        8'hD2 : value <= 8'hFA;
        8'hD3 : value <= 8'hFA;
        8'hD4 : value <= 8'hFA;
        8'hD5 : value <= 8'hFB;
        8'hD6 : value <= 8'hFB;
        8'hD7 : value <= 8'hFB;
        8'hD8 : value <= 8'hFB;
        8'hD9 : value <= 8'hFB;
        8'hDA : value <= 8'hFC;
        8'hDB : value <= 8'hFC;
        8'hDC : value <= 8'hFC;
        8'hDD : value <= 8'hFC;
        8'hDE : value <= 8'hFC;
        8'hDF : value <= 8'hFC;
        8'hE0 : value <= 8'hFD;
        8'hE1 : value <= 8'hFD;
        8'hE2 : value <= 8'hFD;
        8'hE3 : value <= 8'hFD;
        8'hE4 : value <= 8'hFD;
        8'hE5 : value <= 8'hFD;
        8'hE6 : value <= 8'hFD;
        8'hE7 : value <= 8'hFE;
        8'hE8 : value <= 8'hFE;
        8'hE9 : value <= 8'hFE;
        8'hEA : value <= 8'hFE;
        8'hEB : value <= 8'hFE;
        8'hEC : value <= 8'hFE;
        8'hED : value <= 8'hFE;
        8'hEE : value <= 8'hFE;
        8'hEF : value <= 8'hFE;
        8'hF0 : value <= 8'hFE;
        8'hF1 : value <= 8'hFE;
        8'hF2 : value <= 8'hFF;
        8'hF3 : value <= 8'hFF;
        8'hF4 : value <= 8'hFF;
        8'hF5 : value <= 8'hFF;
        8'hF6 : value <= 8'hFF;
        8'hF7 : value <= 8'hFF;
        8'hF8 : value <= 8'hFF;
        8'hF9 : value <= 8'hFF;
        8'hFA : value <= 8'hFF;
        8'hFB : value <= 8'hFF;
        8'hFC : value <= 8'hFF;
        8'hFD : value <= 8'hFF;
        8'hFE : value <= 8'hFF;
        8'hFF : value <= 8'hFF;
    endcase
end

endmodule
