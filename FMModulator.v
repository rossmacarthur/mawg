module FMModulator (
    input clk,
    input [15:0] message,   // signed modulating input
    input [31:0] ctr_ctrl,  // frequency control for center modulating frequency
    input [7:0] deviation,  // controls the deviation from the center frequency
    output [15:0] modulated // signed FM modulated output
);

wire [31:0] crr_ctrl;
wire [47:0] emessage;
wire [47:0] fmessage;
assign emessage = {{32{message[15]}}, message};
assign fmessage = emessage <<< deviation;
assign crr_ctrl = ctr_ctrl + fmessage[47:16];

// Connect up modules
NCO_fm NCO_fm0 (
    .clk     ( clk       ),
    .rst     ( 1'b0      ),
    .ctrl    ( crr_ctrl  ),
  //.phase   ( nco_phase ),
    .sin_out ( modulated )
);

endmodule
