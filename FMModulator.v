module FMModulator (
    input clk,
    input [7:0] message,   // signed modulating input
    input [31:0] ctr_ctrl, // frequency control for center modulating frequency
    input [4:0] deviation, // controls the deviation from the center frequency
    output [7:0] modulated // FM modulated output
);

wire [31:0] crr_ctrl;
wire [31:0] emessage;
assign emessage = {{24{message[7]}}, message[7:0]};
assign crr_ctrl = ctr_ctrl + (emessage <<< deviation);

// Connect up modules
NCO NCO0 (
    .clk     ( clk       ),
    .reset   ( 1'b0      ),
    .ctrl    ( crr_ctrl  ),
    .sin_out ( modulated )
  //.cos_out ( cos_out   )
);

endmodule
