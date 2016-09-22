module FMDemodulator (
    input clk,
    input [15:0] modulated,   // signed modulated input
    input [31:0] ctr_ctrl,    // frequency control for center modulating frequency
	 input [4:0] sample_rate,  // rate to take samples for demodulation
    output [15:0] demodulated // signed FM demodulated output
);

wire [31:0] nco_phase;
wire [15:0] nco_out;
wire [15:0] xored;
wire [15:0] demod;
assign xored = nco_out ^ modulated;
assign demod = {~xored[15], xored[14:0]};

// Connect up modules
NCO_fm NCO_fm0 (
    .clk     ( clk       ),
    .rst     ( 1'b0      ),
    .ctrl    ( ctr_ctrl  ),
    .phase   ( nco_phase ),
    .sin_out ( nco_out   )
);

BlockAverager BlockAverager0 (
    .clk         ( clk         ),
    .phase       ( nco_phase   ),
	 .sample_rate ( sample_rate ),
    .signal      ( demod       ),
    .filtered    ( demodulated )
);

endmodule
