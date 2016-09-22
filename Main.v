module Main (
    input CLK,
	 input TXD,
    input SW,
	 output [15:0] LDS,
    output AUD_PWM,
    output reg AUD_SD=1'b1,
    output JA1,
    output JA2,
    output JA4
);

// Get some different clock speeds
wire CLK_100M;
wire CLK_50M;
wire CLK_75M;
wire CLK_85M;
Clock_Generator Clock_Gen (
    .CLK_IN1  ( CLK      ), // input
    .CLK_OUT1 ( CLK_100M ), // output
    .CLK_OUT2 ( CLK_50M  ), // output
	 .CLK_OUT3 ( CLK_75M  ), // output
	 .CLK_OUT4 ( CLK_85M  )  // output
);
reg CLK_1M;
reg [6:0] CLK_1M_counter;
always @(posedge CLK_100M) if (CLK_1M_counter == 99) begin CLK_1M_counter <= 0; CLK_1M <= 1; end else begin CLK_1M_counter <= CLK_1M_counter + 1'b1; CLK_1M <= 0; end

// Receive via UART new config
wire [7:0] uart_data;
wire uart_busy;

UART_RX UART_RX0 (
    .clk    ( CLK_1M    ), // input 
    .enable ( 1'b1      ), // input
    .RX     ( TXD       ), // input
    .busy   ( uart_busy ), // output
    .data   ( uart_data )  // output [7:0]
);

reg [1:0] mawg_out;
reg [1:0] mawg_wave;
reg [31:0] mawg_ctrl;
reg mawg_chirp_is_down;
reg [3:0] mawg_chirp_delay ;
reg [31:0] mawg_chirp_min_ctrl;
reg [31:0] mawg_chirp_max_ctrl;
reg [31:0] mawg_chirp_inc_rate;
reg [31:0] mawg_chirp_div_rate;
reg [31:0] mawg_pulse_duty_cycle;
reg [31:0] mawg_fm_ctr_ctrl;
reg [7:0] mawg_fm_deviation;
reg [4:0] mawg_fm_demod_rate;

reg [7:0] cmd;
reg [31:0] buff;
reg [2:0] state;
reg prev_busy;

always @(posedge CLK_1M) begin
	if (SW) begin
		cmd <= 8'b0;
		state <= 3'b0;
		buff <= 32'b0;
		mawg_out <= 2'b0;
		mawg_wave <= 2'b0;
		mawg_ctrl <= 32'b0;
		mawg_chirp_is_down <= 1'b0;
		mawg_chirp_delay <= 4'b0;
		mawg_chirp_min_ctrl <= 32'b0;
		mawg_chirp_max_ctrl <= 32'b0;
		mawg_chirp_inc_rate <= 32'b0;
		mawg_chirp_div_rate <= 32'b0;
		mawg_pulse_duty_cycle <= 32'b0;
		mawg_fm_ctr_ctrl <= 32'b0;
		mawg_fm_deviation <= 8'b0;
		mawg_fm_demod_rate <= 5'b0;
	end else begin
		prev_busy <= uart_busy;
		if (~uart_busy & prev_busy) begin
			state <= (state == 3'd4) ? 3'd0 : state + 1'b1;
			if (state == 3'd0)
				cmd <= uart_data;
			else if (state <= 3'd3)
				buff <= { buff[23:0], uart_data };
			else begin
				if (cmd == 8'h0)
					mawg_out <= uart_data[1:0];
				else if (cmd == 8'h1)
					mawg_wave <= uart_data[1:0];
				else if (cmd == 8'h2)
					mawg_ctrl <= { buff[23:0], uart_data };
				else if (cmd == 8'h3)
					mawg_chirp_is_down <= uart_data[0];
				else if (cmd == 8'h4)
					mawg_chirp_delay <= uart_data[3:0];
				else if (cmd == 8'h5)
					mawg_chirp_min_ctrl <= { buff[23:0], uart_data };
				else if (cmd == 8'h6)
					mawg_chirp_max_ctrl <= { buff[23:0], uart_data };
				else if (cmd == 8'h7)
					mawg_chirp_div_rate <= { buff[23:0], uart_data };
				else if (cmd == 8'h8)
					mawg_chirp_inc_rate <= { buff[23:0], uart_data };
				else if (cmd == 8'h9)
					mawg_pulse_duty_cycle <= { buff[23:0], uart_data };
				else if (cmd == 8'hA)
					mawg_fm_ctr_ctrl <= { buff[23:0], uart_data };
				else if (cmd == 8'hB)
					mawg_fm_deviation <= uart_data;
				else if (cmd == 8'hC)
					mawg_fm_demod_rate <= uart_data[4:0];
				else if (cmd == 8'hF) begin
					mawg_out <= 2'b0;
					mawg_wave <= 2'b0;
					mawg_ctrl <= 32'b0;
					mawg_chirp_is_down <= 1'b0;
					mawg_chirp_delay <= 4'b0;
					mawg_chirp_min_ctrl <= 32'b0;
					mawg_chirp_max_ctrl <= 32'b0;
					mawg_chirp_inc_rate <= 32'b0;
					mawg_chirp_div_rate <= 32'b0;
					mawg_pulse_duty_cycle <= 32'b0;
					mawg_fm_ctr_ctrl <= 32'b0;
					mawg_fm_deviation <= 8'b0;
					mawg_fm_demod_rate <= 5'b0;
				end
			end
		end
	end
end

// Instantiate the MAWG
wire [15:0] signal;
MAWG MAWG0 (
	.clk              ( CLK_100M               ), // input
	.out_sel          ( mawg_out               ), // input [1:0]
	.wave_sel         ( mawg_wave              ), // input [1:0]
	.freq_ctrl        ( mawg_ctrl              ), // input [31:0]
	.chirp_is_down    ( mawg_chirp_is_down     ), // input
	.chirp_delay      ( mawg_chirp_delay       ), // input [3:0]
	.chirp_min_ctrl   ( mawg_chirp_min_ctrl    ), // input [31:0]
   .chirp_max_ctrl   ( mawg_chirp_max_ctrl    ), // input [31:0]
   .chirp_inc_rate   ( mawg_chirp_inc_rate    ), // input [31:0]
   .chirp_div_rate   ( mawg_chirp_div_rate    ), // input [31:0]
	.pulse_duty_cycle ( mawg_pulse_duty_cycle  ), // input [31:0]
	.fm_ctr_ctrl      ( mawg_fm_ctr_ctrl       ), // input [31:0]
	.fm_deviation     ( mawg_fm_deviation      ), // input [7:0]
	.fm_demod_rate    ( mawg_fm_demod_rate     ), // input [4:0]
	.signal           ( signal                 )  // output [7:0]
);

// Setup PmodDA4 and audio jack outputs
wire [11:0] to_pmod;
wire [7:0] to_audio;
assign to_pmod = {~signal[15], signal[14:4]};
assign to_audio = {~signal[15], signal[14:8]};
PmodDA4_Control PmodDA4_Control0 (
    .clk    ( CLK_75M ), // input
	 .rst    ( 1'b0    ), // input
	 .signal ( to_pmod ), // input [11:0]
	 .SYNC   ( JA1     ), // output
	 .DATA   ( JA2     ), // output
	 .SCLK   ( JA4     )  // output
);
Audio Audio0 (
    .clk     ( CLK_100M ), // input
    .value   ( to_audio ), // input [7:0]
    .AUD_PWM ( AUD_PWM  )  // output
);

endmodule
