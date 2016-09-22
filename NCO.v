// Sine and cosine wave generator module
// Phase incremented quarter LUT Numerically Controlled Oscillator
// Author: Ross MacArthur
//   16-bit signed output amplitude
//   32-bit input frequency control
//   frequency = clk * ctrl / 2^32

module NCO (
    input clk,
    input rst,
    input [31:0] ctrl,        // frequency control word
    output reg [15:0] sin_out, // signed amplitude of sine wave
    output reg [15:0] cos_out  // signed amplitude of cosine wave
);

// Phase Accumulator
reg [31:0] phase;

always @(posedge clk) begin
    if (rst)
        phase <= 32'h0;
    else
        phase <= phase + ctrl;
end

// Quarter Sine Look-up Table
reg [5:0] sin_lut_sel;
reg [5:0] cos_lut_sel;
reg [15:0] sin_lut_val;
reg [15:0] cos_lut_val;

always @(*) begin
    sin_lut_sel <= phase[30] ? ~(phase[29:24]-1'b1) : phase[29:24];
    cos_lut_sel <= phase[30] ? ~(phase[29:24]-1'b1) : phase[29:24];
    if (phase[30] & ~|phase[29:24]) begin
        sin_out <= phase[31] ? 16'b10000000_00000001 : 16'b01111111_11111111;
        cos_out <= 16'b0;
    end else begin
        sin_out <= phase[31] ? (~sin_lut_val+1'b1) : sin_lut_val;
        cos_out <= (phase[31]^phase[30]) ? (~cos_lut_val+1'b1) : cos_lut_val;
    end
    
    case(sin_lut_sel)
        6'h00 : sin_lut_val <= 16'h0000;
        6'h01 : sin_lut_val <= 16'h0324;
        6'h02 : sin_lut_val <= 16'h0648;
        6'h03 : sin_lut_val <= 16'h096A;
        6'h04 : sin_lut_val <= 16'h0C8C;
        6'h05 : sin_lut_val <= 16'h0FAB;
        6'h06 : sin_lut_val <= 16'h12C8;
        6'h07 : sin_lut_val <= 16'h15E2;
        6'h08 : sin_lut_val <= 16'h18F9;
        6'h09 : sin_lut_val <= 16'h1C0B;
        6'h0A : sin_lut_val <= 16'h1F1A;
        6'h0B : sin_lut_val <= 16'h2223;
        6'h0C : sin_lut_val <= 16'h2528;
        6'h0D : sin_lut_val <= 16'h2826;
        6'h0E : sin_lut_val <= 16'h2B1F;
        6'h0F : sin_lut_val <= 16'h2E11;
        6'h10 : sin_lut_val <= 16'h30FB;
        6'h11 : sin_lut_val <= 16'h33DF;
        6'h12 : sin_lut_val <= 16'h36BA;
        6'h13 : sin_lut_val <= 16'h398C;
        6'h14 : sin_lut_val <= 16'h3C56;
        6'h15 : sin_lut_val <= 16'h3F17;
        6'h16 : sin_lut_val <= 16'h41CE;
        6'h17 : sin_lut_val <= 16'h447A;
        6'h18 : sin_lut_val <= 16'h471C;
        6'h19 : sin_lut_val <= 16'h49B4;
        6'h1A : sin_lut_val <= 16'h4C3F;
        6'h1B : sin_lut_val <= 16'h4EBF;
        6'h1C : sin_lut_val <= 16'h5133;
        6'h1D : sin_lut_val <= 16'h539B;
        6'h1E : sin_lut_val <= 16'h55F5;
        6'h1F : sin_lut_val <= 16'h5842;
        6'h20 : sin_lut_val <= 16'h5A82;
        6'h21 : sin_lut_val <= 16'h5CB3;
        6'h22 : sin_lut_val <= 16'h5ED7;
        6'h23 : sin_lut_val <= 16'h60EB;
        6'h24 : sin_lut_val <= 16'h62F1;
        6'h25 : sin_lut_val <= 16'h64E8;
        6'h26 : sin_lut_val <= 16'h66CF;
        6'h27 : sin_lut_val <= 16'h68A6;
        6'h28 : sin_lut_val <= 16'h6A6D;
        6'h29 : sin_lut_val <= 16'h6C23;
        6'h2A : sin_lut_val <= 16'h6DC9;
        6'h2B : sin_lut_val <= 16'h6F5E;
        6'h2C : sin_lut_val <= 16'h70E2;
        6'h2D : sin_lut_val <= 16'h7254;
        6'h2E : sin_lut_val <= 16'h73B5;
        6'h2F : sin_lut_val <= 16'h7504;
        6'h30 : sin_lut_val <= 16'h7641;
        6'h31 : sin_lut_val <= 16'h776B;
        6'h32 : sin_lut_val <= 16'h7884;
        6'h33 : sin_lut_val <= 16'h7989;
        6'h34 : sin_lut_val <= 16'h7A7C;
        6'h35 : sin_lut_val <= 16'h7B5C;
        6'h36 : sin_lut_val <= 16'h7C29;
        6'h37 : sin_lut_val <= 16'h7CE3;
        6'h38 : sin_lut_val <= 16'h7D89;
        6'h39 : sin_lut_val <= 16'h7E1D;
        6'h3A : sin_lut_val <= 16'h7E9C;
        6'h3B : sin_lut_val <= 16'h7F09;
        6'h3C : sin_lut_val <= 16'h7F61;
        6'h3D : sin_lut_val <= 16'h7FA6;
        6'h3E : sin_lut_val <= 16'h7FD8;
        6'h3F : sin_lut_val <= 16'h7FF5;
    endcase
    
    case(cos_lut_sel)
        6'h00 : cos_lut_val <= 16'h7FFF;
        6'h01 : cos_lut_val <= 16'h7FF5;
        6'h02 : cos_lut_val <= 16'h7FD8;
        6'h03 : cos_lut_val <= 16'h7FA6;
        6'h04 : cos_lut_val <= 16'h7F61;
        6'h05 : cos_lut_val <= 16'h7F09;
        6'h06 : cos_lut_val <= 16'h7E9C;
        6'h07 : cos_lut_val <= 16'h7E1D;
        6'h08 : cos_lut_val <= 16'h7D89;
        6'h09 : cos_lut_val <= 16'h7CE3;
        6'h0A : cos_lut_val <= 16'h7C29;
        6'h0B : cos_lut_val <= 16'h7B5C;
        6'h0C : cos_lut_val <= 16'h7A7C;
        6'h0D : cos_lut_val <= 16'h7989;
        6'h0E : cos_lut_val <= 16'h7884;
        6'h0F : cos_lut_val <= 16'h776B;
        6'h10 : cos_lut_val <= 16'h7641;
        6'h11 : cos_lut_val <= 16'h7504;
        6'h12 : cos_lut_val <= 16'h73B5;
        6'h13 : cos_lut_val <= 16'h7254;
        6'h14 : cos_lut_val <= 16'h70E2;
        6'h15 : cos_lut_val <= 16'h6F5E;
        6'h16 : cos_lut_val <= 16'h6DC9;
        6'h17 : cos_lut_val <= 16'h6C23;
        6'h18 : cos_lut_val <= 16'h6A6D;
        6'h19 : cos_lut_val <= 16'h68A6;
        6'h1A : cos_lut_val <= 16'h66CF;
        6'h1B : cos_lut_val <= 16'h64E8;
        6'h1C : cos_lut_val <= 16'h62F1;
        6'h1D : cos_lut_val <= 16'h60EB;
        6'h1E : cos_lut_val <= 16'h5ED7;
        6'h1F : cos_lut_val <= 16'h5CB3;
        6'h20 : cos_lut_val <= 16'h5A82;
        6'h21 : cos_lut_val <= 16'h5842;
        6'h22 : cos_lut_val <= 16'h55F5;
        6'h23 : cos_lut_val <= 16'h539B;
        6'h24 : cos_lut_val <= 16'h5133;
        6'h25 : cos_lut_val <= 16'h4EBF;
        6'h26 : cos_lut_val <= 16'h4C3F;
        6'h27 : cos_lut_val <= 16'h49B4;
        6'h28 : cos_lut_val <= 16'h471C;
        6'h29 : cos_lut_val <= 16'h447A;
        6'h2A : cos_lut_val <= 16'h41CE;
        6'h2B : cos_lut_val <= 16'h3F17;
        6'h2C : cos_lut_val <= 16'h3C56;
        6'h2D : cos_lut_val <= 16'h398C;
        6'h2E : cos_lut_val <= 16'h36BA;
        6'h2F : cos_lut_val <= 16'h33DF;
        6'h30 : cos_lut_val <= 16'h30FB;
        6'h31 : cos_lut_val <= 16'h2E11;
        6'h32 : cos_lut_val <= 16'h2B1F;
        6'h33 : cos_lut_val <= 16'h2826;
        6'h34 : cos_lut_val <= 16'h2528;
        6'h35 : cos_lut_val <= 16'h2223;
        6'h36 : cos_lut_val <= 16'h1F1A;
        6'h37 : cos_lut_val <= 16'h1C0B;
        6'h38 : cos_lut_val <= 16'h18F9;
        6'h39 : cos_lut_val <= 16'h15E2;
        6'h3A : cos_lut_val <= 16'h12C8;
        6'h3B : cos_lut_val <= 16'h0FAB;
        6'h3C : cos_lut_val <= 16'h0C8C;
        6'h3D : cos_lut_val <= 16'h096A;
        6'h3E : cos_lut_val <= 16'h0648;
        6'h3F : cos_lut_val <= 16'h0324;   
    endcase
end

endmodule
