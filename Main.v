module Main (
    input CLK_100M,
    input [15:0] SW,
    output AUD_PWM,
    output reg AUD_SD=1'b1
);

// Modulate
wire [7:0] message;
wire [7:0] modulated;
reg [31:0] carrier_ctrl;
reg [7:0] umessage;
reg is_negative;
always @(*) begin
    carrier_ctrl <= is_negative ? 32'h1F751 - {umessage,8'b0} : 32'h1F751 + {umessage,8'b0};
    umessage <= message[7] ? ~message[7:0]+1'b1 : message[7:0];
    is_negative <= message[7];
end

// Select output
wire [7:0] to_audio;
assign to_audio = SW[15] ? modulated : message;

// Connect up modules
NCO NCO0 (
    .clk     ( CLK_100M ), // input
    .reset   ( 1'b0     ), // input
    .ctrl    ( 32'h10C7 ), // input [31:0]
    .sin_out ( message  )  // output [7:0]
    //.cos_out ( cos_out )  // output [7:0]
);

NCO NCO1 (
    .clk     ( CLK_100M     ), // input
    .reset   ( 1'b0         ), // input
    .ctrl    ( carrier_ctrl ), // input [31:0]
    .sin_out ( modulated    )  // output [7:0]
    //.cos_out ( cos_out )  // output [7:0]
);

Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( to_audio ), // input [3:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
