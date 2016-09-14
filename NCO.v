// Sine and cosine wave generator module
// Phase incremented quarter LUT Numerically Controlled Oscillator
// Author: Ross MacArthur
//   8-bit signed output amplitude
//   32-bit input frequency control
//   frequency = clk * ctrl / 2^32

module NCO (
    input clk,
    input reset,
    input [31:0] ctrl,        // frequency control word
    output reg [31:0] phase,
    output reg [7:0] sin_out, // signed amplitude of sine wave
    output reg [7:0] cos_out  // signed amplitude of cosine wave
);

// Phase Accumulator
//reg [31:0] phase;

always @(posedge clk) begin
    if (reset)
        phase <= 32'h0;
    else
        phase <= phase + ctrl;
end

// Quarter Sine Look-up Table
reg [5:0] sin_lut_sel;
reg [5:0] cos_lut_sel;
reg [7:0] sin_lut_val;
reg [7:0] cos_lut_val;

always @(*) begin
    sin_lut_sel <= phase[30] ? ~(phase[29:24]-1'b1) : phase[29:24];
    cos_lut_sel <= phase[30] ? ~(phase[29:24]-1'b1) : phase[29:24];
    if (phase[30] & ~|phase[29:24]) begin
        sin_out <= phase[31] ? 8'b10000001 : 8'b01111111;
        cos_out <= 8'b00000000;
    end else begin
        sin_out <= phase[31] ? (~sin_lut_val+1'b1) : sin_lut_val;
        cos_out <= (phase[31]^phase[30]) ? (~cos_lut_val+1'b1) : cos_lut_val;
    end
    
    case(sin_lut_sel)
        6'h00 : sin_lut_val <= 8'h00;
        6'h01 : sin_lut_val <= 8'h03;
        6'h02 : sin_lut_val <= 8'h06;
        6'h03 : sin_lut_val <= 8'h09;
        6'h04 : sin_lut_val <= 8'h0C;
        6'h05 : sin_lut_val <= 8'h10;
        6'h06 : sin_lut_val <= 8'h13;
        6'h07 : sin_lut_val <= 8'h16;
        6'h08 : sin_lut_val <= 8'h19;
        6'h09 : sin_lut_val <= 8'h1C;
        6'h0A : sin_lut_val <= 8'h1F;
        6'h0B : sin_lut_val <= 8'h22;
        6'h0C : sin_lut_val <= 8'h25;
        6'h0D : sin_lut_val <= 8'h28;
        6'h0E : sin_lut_val <= 8'h2B;
        6'h0F : sin_lut_val <= 8'h2E;
        6'h10 : sin_lut_val <= 8'h31;
        6'h11 : sin_lut_val <= 8'h33;
        6'h12 : sin_lut_val <= 8'h36;
        6'h13 : sin_lut_val <= 8'h39;
        6'h14 : sin_lut_val <= 8'h3C;
        6'h15 : sin_lut_val <= 8'h3F;
        6'h16 : sin_lut_val <= 8'h41;
        6'h17 : sin_lut_val <= 8'h44;
        6'h18 : sin_lut_val <= 8'h47;
        6'h19 : sin_lut_val <= 8'h49;
        6'h1A : sin_lut_val <= 8'h4C;
        6'h1B : sin_lut_val <= 8'h4E;
        6'h1C : sin_lut_val <= 8'h51;
        6'h1D : sin_lut_val <= 8'h53;
        6'h1E : sin_lut_val <= 8'h55;
        6'h1F : sin_lut_val <= 8'h58;
        6'h20 : sin_lut_val <= 8'h5A;
        6'h21 : sin_lut_val <= 8'h5C;
        6'h22 : sin_lut_val <= 8'h5E;
        6'h23 : sin_lut_val <= 8'h60;
        6'h24 : sin_lut_val <= 8'h62;
        6'h25 : sin_lut_val <= 8'h64;
        6'h26 : sin_lut_val <= 8'h66;
        6'h27 : sin_lut_val <= 8'h68;
        6'h28 : sin_lut_val <= 8'h6A;
        6'h29 : sin_lut_val <= 8'h6B;
        6'h2A : sin_lut_val <= 8'h6D;
        6'h2B : sin_lut_val <= 8'h6F;
        6'h2C : sin_lut_val <= 8'h70;
        6'h2D : sin_lut_val <= 8'h71;
        6'h2E : sin_lut_val <= 8'h73;
        6'h2F : sin_lut_val <= 8'h74;
        6'h30 : sin_lut_val <= 8'h75;
        6'h31 : sin_lut_val <= 8'h76;
        6'h32 : sin_lut_val <= 8'h78;
        6'h33 : sin_lut_val <= 8'h79;
        6'h34 : sin_lut_val <= 8'h7A;
        6'h35 : sin_lut_val <= 8'h7A;
        6'h36 : sin_lut_val <= 8'h7B;
        6'h37 : sin_lut_val <= 8'h7C;
        6'h38 : sin_lut_val <= 8'h7D;
        6'h39 : sin_lut_val <= 8'h7D;
        6'h3A : sin_lut_val <= 8'h7E;
        6'h3B : sin_lut_val <= 8'h7E;
        6'h3C : sin_lut_val <= 8'h7E;
        6'h3D : sin_lut_val <= 8'h7F;
        6'h3E : sin_lut_val <= 8'h7F;
        6'h3F : sin_lut_val <= 8'h7F;
    endcase
    
    case(cos_lut_sel)
        6'h00 : cos_lut_val <= 8'h7F;
        6'h01 : cos_lut_val <= 8'h7F;
        6'h02 : cos_lut_val <= 8'h7F;
        6'h03 : cos_lut_val <= 8'h7F;
        6'h04 : cos_lut_val <= 8'h7E;
        6'h05 : cos_lut_val <= 8'h7E;
        6'h06 : cos_lut_val <= 8'h7E;
        6'h07 : cos_lut_val <= 8'h7D;
        6'h08 : cos_lut_val <= 8'h7D;
        6'h09 : cos_lut_val <= 8'h7C;
        6'h0A : cos_lut_val <= 8'h7B;
        6'h0B : cos_lut_val <= 8'h7A;
        6'h0C : cos_lut_val <= 8'h7A;
        6'h0D : cos_lut_val <= 8'h79;
        6'h0E : cos_lut_val <= 8'h78;
        6'h0F : cos_lut_val <= 8'h76;
        6'h10 : cos_lut_val <= 8'h75;
        6'h11 : cos_lut_val <= 8'h74;
        6'h12 : cos_lut_val <= 8'h73;
        6'h13 : cos_lut_val <= 8'h71;
        6'h14 : cos_lut_val <= 8'h70;
        6'h15 : cos_lut_val <= 8'h6F;
        6'h16 : cos_lut_val <= 8'h6D;
        6'h17 : cos_lut_val <= 8'h6B;
        6'h18 : cos_lut_val <= 8'h6A;
        6'h19 : cos_lut_val <= 8'h68;
        6'h1A : cos_lut_val <= 8'h66;
        6'h1B : cos_lut_val <= 8'h64;
        6'h1C : cos_lut_val <= 8'h62;
        6'h1D : cos_lut_val <= 8'h60;
        6'h1E : cos_lut_val <= 8'h5E;
        6'h1F : cos_lut_val <= 8'h5C;
        6'h20 : cos_lut_val <= 8'h5A;
        6'h21 : cos_lut_val <= 8'h58;
        6'h22 : cos_lut_val <= 8'h55;
        6'h23 : cos_lut_val <= 8'h53;
        6'h24 : cos_lut_val <= 8'h51;
        6'h25 : cos_lut_val <= 8'h4E;
        6'h26 : cos_lut_val <= 8'h4C;
        6'h27 : cos_lut_val <= 8'h49;
        6'h28 : cos_lut_val <= 8'h47;
        6'h29 : cos_lut_val <= 8'h44;
        6'h2A : cos_lut_val <= 8'h41;
        6'h2B : cos_lut_val <= 8'h3F;
        6'h2C : cos_lut_val <= 8'h3C;
        6'h2D : cos_lut_val <= 8'h39;
        6'h2E : cos_lut_val <= 8'h36;
        6'h2F : cos_lut_val <= 8'h33;
        6'h30 : cos_lut_val <= 8'h31;
        6'h31 : cos_lut_val <= 8'h2E;
        6'h32 : cos_lut_val <= 8'h2B;
        6'h33 : cos_lut_val <= 8'h28;
        6'h34 : cos_lut_val <= 8'h25;
        6'h35 : cos_lut_val <= 8'h22;
        6'h36 : cos_lut_val <= 8'h1F;
        6'h37 : cos_lut_val <= 8'h1C;
        6'h38 : cos_lut_val <= 8'h19;
        6'h39 : cos_lut_val <= 8'h16;
        6'h3A : cos_lut_val <= 8'h13;
        6'h3B : cos_lut_val <= 8'h10;
        6'h3C : cos_lut_val <= 8'h0C;
        6'h3D : cos_lut_val <= 8'h09;
        6'h3E : cos_lut_val <= 8'h06;
        6'h3F : cos_lut_val <= 8'h03;    
    endcase
end

endmodule
