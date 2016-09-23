// Simple 8-bit UART receiver
// Author: Ross MacArthur
// Samples input line at 16 times the baudrate

module UART_RX (
  input clk,            // 16 * baudrate
  input rst,            // enable receiver
  input RX,             // UART receive line
  output reg busy,      // high when receiving
  output reg [7:0] data // received data
);

reg RX_d;
reg [9:0] datafill;
reg [3:0] index;
reg [3:0] sampler;

always @(posedge clk) begin
  RX_d <= RX;
  if (rst) begin
    busy <= 1'b0;
    datafill <= 10'b0;
    index <= 4'b0;
    sampler <= 4'b0;
  end else begin
    if (~busy & ~RX_d) begin
      busy <= 1'b1;
      sampler <= 4'b0;
      index <= 4'b0;
    end
    if (busy) begin
      sampler <= sampler + 1'b1;
      if (sampler == 4'd7) begin
        if (RX_d & ~|index) 
          busy <= 1'b0;
        else begin
          index <= index + 1'b1;
          datafill[index] <= RX_d;
          if (index == 9) begin
            data <= datafill[8:1];
            index <= 4'b0;
            busy <= 1'b0;
          end
        end
      end
    end
  end
end

endmodule
