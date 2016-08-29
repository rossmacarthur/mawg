// Phase incremented quarter LUT NCO (sine output only)
// Author: Ross MacArthur
//   32-bit input phase increment control
//   8-bit signed output amplitude
//   frequency = clk * control / 2^32

module NCO (
    input clk,
    input reset,
    input [31:0] control,      // frequency control word
    output reg [7:0] amplitude // signed output amplitude of wave
);

// Phase Accumulator
reg [31:0] phase;

always @(posedge clk) begin
    if (reset) begin
        phase <= 32'h0;
    end else
        phase <= phase + control;
end

// Quarter Sine Look-up Table
reg [5:0] lut_select;
reg [7:0] lut_value;

always @(*) begin
    lut_select <= phase[30] ? ~(phase[29:24]-1'b1) : phase[29:24];
    if (phase[30] & ~|phase[29:24])
        amplitude <= phase[31] ? 8'b10000001 : 8'b01111111;
    else
        amplitude <= phase[31] ? (~lut_value+1'b1) : lut_value;

    case(lut_select)
        6'h00 : lut_value <= 8'h00;
        6'h01 : lut_value <= 8'h03;
        6'h02 : lut_value <= 8'h06;
        6'h03 : lut_value <= 8'h09;
        6'h04 : lut_value <= 8'h0C;
        6'h05 : lut_value <= 8'h10;
        6'h06 : lut_value <= 8'h13;
        6'h07 : lut_value <= 8'h16;
        6'h08 : lut_value <= 8'h19;
        6'h09 : lut_value <= 8'h1C;
        6'h0A : lut_value <= 8'h1F;
        6'h0B : lut_value <= 8'h22;
        6'h0C : lut_value <= 8'h25;
        6'h0D : lut_value <= 8'h28;
        6'h0E : lut_value <= 8'h2B;
        6'h0F : lut_value <= 8'h2E;
        6'h10 : lut_value <= 8'h31;
        6'h11 : lut_value <= 8'h33;
        6'h12 : lut_value <= 8'h36;
        6'h13 : lut_value <= 8'h39;
        6'h14 : lut_value <= 8'h3C;
        6'h15 : lut_value <= 8'h3F;
        6'h16 : lut_value <= 8'h41;
        6'h17 : lut_value <= 8'h44;
        6'h18 : lut_value <= 8'h47;
        6'h19 : lut_value <= 8'h49;
        6'h1A : lut_value <= 8'h4C;
        6'h1B : lut_value <= 8'h4E;
        6'h1C : lut_value <= 8'h51;
        6'h1D : lut_value <= 8'h53;
        6'h1E : lut_value <= 8'h55;
        6'h1F : lut_value <= 8'h58;
        6'h20 : lut_value <= 8'h5A;
        6'h21 : lut_value <= 8'h5C;
        6'h22 : lut_value <= 8'h5E;
        6'h23 : lut_value <= 8'h60;
        6'h24 : lut_value <= 8'h62;
        6'h25 : lut_value <= 8'h64;
        6'h26 : lut_value <= 8'h66;
        6'h27 : lut_value <= 8'h68;
        6'h28 : lut_value <= 8'h6A;
        6'h29 : lut_value <= 8'h6B;
        6'h2A : lut_value <= 8'h6D;
        6'h2B : lut_value <= 8'h6F;
        6'h2C : lut_value <= 8'h70;
        6'h2D : lut_value <= 8'h71;
        6'h2E : lut_value <= 8'h73;
        6'h2F : lut_value <= 8'h74;
        6'h30 : lut_value <= 8'h75;
        6'h31 : lut_value <= 8'h76;
        6'h32 : lut_value <= 8'h78;
        6'h33 : lut_value <= 8'h79;
        6'h34 : lut_value <= 8'h7A;
        6'h35 : lut_value <= 8'h7A;
        6'h36 : lut_value <= 8'h7B;
        6'h37 : lut_value <= 8'h7C;
        6'h38 : lut_value <= 8'h7D;
        6'h39 : lut_value <= 8'h7D;
        6'h3A : lut_value <= 8'h7E;
        6'h3B : lut_value <= 8'h7E;
        6'h3C : lut_value <= 8'h7E;
        6'h3D : lut_value <= 8'h7F;
        6'h3E : lut_value <= 8'h7F;
        6'h3F : lut_value <= 8'h7F;
    endcase
end

endmodule
