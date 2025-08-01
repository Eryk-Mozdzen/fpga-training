
// offset       name        fields
// 0x00000000   STATUS  R   NNNNNNNNNNNNNNNNxxxxxxxxxxxxxxxC
// 0x00000004   CTRL    W   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxW
// 0x00000008   LED0    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB
// 0x0000000C   LED1    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB
// ...          ...     ..  ...
// ...          LEDn    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB

module ws2812b #(
        parameter CASCADE_LENGTH = 1,
        parameter CLK_FREQ = 1e6
    ) (
        input wire          clk,
        input wire          reset_n,
        input wire          sel,
        input wire [3:0]    wstrb,
        input wire [10:0]   addrxd,
        input wire [31:0]   wdata,
        output wire [31:0]  rdata,
        output wire         ready,
        output reg          din
    );

    // assume that CASCADE_LENGTH = 1
    // don't care about mcu control

    localparam T0H_DURATION = $rtoi(CLK_FREQ*0.40e-6 + 0.5);
    localparam T0L_DURATION = $rtoi(CLK_FREQ*0.85e-6 + 0.5);
    localparam T1H_DURATION = $rtoi(CLK_FREQ*0.80e-6 + 0.5);
    localparam T1L_DURATION = $rtoi(CLK_FREQ*0.45e-6 + 0.5);
    localparam RES_DURATION = $rtoi(CLK_FREQ*300e-6 + 0.5);

    localparam STATE_IDLE   = 2'b00;
    localparam STATE_TxH    = 2'b01;
    localparam STATE_TxL    = 2'b10;
    localparam STATE_RES    = 2'b11;

    reg [23:0]  value;
    reg [1:0]   state = STATE_IDLE;
    reg [4:0]   remaining;
    reg [31:0]  counter;

    always @(posedge clk) begin
        case (state)
            STATE_IDLE: begin
                value <= 24'hCF80F2;
                remaining <= 24;

                state <= STATE_TxH;
                counter <= 0;
                din <= 1'b1;
            end
            STATE_TxH: begin
                if ((counter + 1) >= (value[remaining - 1] ? T1H_DURATION : T0H_DURATION)) begin
                    state <= STATE_TxL;
                    counter <= 0;
                    din <= 1'b0;
                end else begin
                    counter <= counter + 1;
                end
            end
            STATE_TxL: begin
                if ((counter + 1) >= (value[remaining - 1] ? T1L_DURATION : T0L_DURATION)) begin
                    counter <= 0;
                    if (remaining == 1) begin
                        state <= STATE_RES;
                        din <= 1'b0;
                    end else begin
                        remaining <= remaining - 1;
                        state <= STATE_TxH;
                        counter <= 0;
                        din <= 1'b1;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end
            STATE_RES: begin
                if ((counter + 1) >= RES_DURATION) begin
                    state <= STATE_IDLE;
                end else begin
                    counter <= counter + 1;
                end
            end
        endcase
    end

    assign rdata = 32'h0;
    assign ready = 0;

endmodule
