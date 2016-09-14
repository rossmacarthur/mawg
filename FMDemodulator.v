module FMDemodulator (
    input clk,
    input [7:0] modulated,   // signed modulated input
    input [31:0] ctr_ctrl,   // frequency control for center modulating frequency
    output [7:0] demodulated // signed FM demodulated output
);

wire [31:0] smp_rate;
wire [7:0] sin_out;
wire [7:0] xored;
assign xored = sin_out ^ modulated;
assign demodulated = {~xored[7], xored[6:0]};

NCO NCO0 (
    .clk     ( clk      ),
    .reset   ( 1'b0     ),
    .phase   ( smp_rate ),
    .ctrl    ( ctr_ctrl ),
    .sin_out ( sin_out  )
  //.cos_out ( cos_out  )
);

endmodule
