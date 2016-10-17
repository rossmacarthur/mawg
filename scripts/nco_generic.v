// Generic Verilog NCO used in hdl_cli.py
// Sine and cosine wave generator
// Phase incremented, quarter LUT, Numerically Controlled Oscillator
// Author: Ross MacArthur
//   {MM}-bit signed output amplitude
//   N-bit input frequency control
//   frequency = clk * ctrl / 2^32

module NCO #(N = 32)(
  input clk,
  input rst,
  input [N-1:0] ctrl,        // frequency control word
  output reg [{M}:0] sin_out, // signed amplitude of sine wave
  output reg [{M}:0] cos_out  // signed amplitude of cosine wave
);

// Phase Accumulator
reg [N-1:0] phase;

always @(posedge clk) begin
  if (rst)
    phase <= {{N{{1'b0}}}};
  else
    phase <= phase + ctrl;
end

// Quarter Sine Look-up Table
reg [{K}:0] sin_lut_sel;
reg [{K}:0] cos_lut_sel;
reg [{M}:0] sin_lut_val;
reg [{M}:0] cos_lut_val;

always @(*) begin
  sin_lut_sel <= phase[N-2] ? ~(phase[N-3:N-8]-1'b1) : phase[N-3:N-8];
  cos_lut_sel <= phase[N-2] ? ~(phase[N-3:N-8]-1'b1) : phase[N-3:N-8];
  if (phase[N-2] & ~|phase[N-3:N-8]) begin
    sin_out <= phase[N-1] ? {sin_min} : {sin_max};
    cos_out <= {cos_zero};
  end else begin
    sin_out <= phase[N-1] ? (~sin_lut_val+1'b1) : sin_lut_val;
    cos_out <= (phase[N-1]^phase[N-2]) ? (~cos_lut_val+1'b1) : cos_lut_val;
  end
  
  case(sin_lut_sel)
{sin_lut}
  endcase
  
  case(cos_lut_sel)
{cos_lut}
  endcase
end

endmodule