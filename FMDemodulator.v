module FMDemodulator (
    input clk,
    input [7:0] modulated,   // signed modulated input
    input [31:0] ctr_ctrl,   // frequency control for center modulating frequency
    output [7:0] demodulated // signed FM demodulated output
);

wire [31:0] nco_phase;
wire [7:0] nco_out;
wire [7:0] xored;
wire [7:0] demod;
assign xored = nco_out ^ modulated;
assign demod = {~xored[7], xored[6:0]};

// Connect up modules
NCO_fm NCO_fm0 (
    .clk     ( clk       ),
    .rst     ( 1'b0      ),
    .ctrl    ( ctr_ctrl  ),
    .phase   ( nco_phase ),
    .sin_out ( nco_out   )
);

BlockAverager BlockAverager0 (
    .clk      ( clk         ),
    .phase    ( nco_phase   ),
    .signal   ( demod       ),
    .filtered ( demodulated )
);

endmodule
