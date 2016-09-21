module UART_RX (
    input clk,            // 16 * baudrate
    input enable,         // enable receiver
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
    if (enable) begin
        if (~busy & ~RX_d) begin
            busy <= 1;
            sampler <= 0;
            index <= 0;
        end
        if (busy) begin
            sampler <= sampler + 1'b1;
            if (sampler == 7) begin
                if (RX_d & ~|index) 
                    busy <= 0;
                else begin
                    index <= index + 1'b1;
                    datafill[index] <= RX_d;
                    if (index == 9) begin
								data <= datafill[8:1];
                        index <= 0;
                        busy <= 0;
                    end
                end
            end
        end
    end
end

endmodule
