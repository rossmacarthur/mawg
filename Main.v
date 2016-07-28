module Main (
    input CLK_100M,
    input SWX,
    input [7:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

wire [7:0] value;
wire [7:0] sinval;
wire [7:0] cosval;

assign value = SWX ? sinval : cosval;

// Divide clock
wire CLK_NCO;
reg [14:0] count;
always @(posedge CLK_100M) count <= count + 1'b1;
assign CLK_NCO = count[14];

// Connect up modules
NCO NCO0 (
    .clk      ( CLK_NCO ), // input
    .enable   ( 1'b1    ), // input
    .phaseinc ( SW      ), // input [7:0]
    .sinval   ( sinval  ), // output [7:0]
    .cosval   ( cosval  )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( value    ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
