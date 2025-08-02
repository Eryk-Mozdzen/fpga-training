module ws2812b #(
    parameter CLK_FREQ = 1e6
) (
    input wire          clk,
    input wire          resetn,
    input wire          sel,
    input wire [15:0]   addr,
    input wire [3:0]    wstrb,
    input wire [31:0]   wdata,
    output wire [31:0]  rdata,
    output wire         ready,
    output reg          din
);

    localparam T0H_DURATION = $rtoi(CLK_FREQ*0.40e-6 + 0.5);
    localparam T0L_DURATION = $rtoi(CLK_FREQ*0.85e-6 + 0.5);
    localparam T1H_DURATION = $rtoi(CLK_FREQ*0.80e-6 + 0.5);
    localparam T1L_DURATION = $rtoi(CLK_FREQ*0.45e-6 + 0.5);
    localparam RES_DURATION = $rtoi(CLK_FREQ*300e-6 + 0.5);

    localparam STATE_IDLE   = 2'b00;
    localparam STATE_TxH    = 2'b01;
    localparam STATE_TxL    = 2'b10;
    localparam STATE_RESET  = 2'b11;

    reg [23:0]  value;
    reg [1:0]   state;
    reg [4:0]   remaining;
    reg [31:0]  counter;

    assign rdata = {8'b0, value[15:8], value[23:16], value[7:0]};
    assign ready = sel;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= STATE_IDLE;
            value <= 0;
            din <= 0;
        end else begin
            if (sel && (state == STATE_IDLE)) begin
                if (wstrb[0]) value[ 7: 0] <= wdata[ 7: 0];
                if (wstrb[1]) value[23:16] <= wdata[15: 8];
                if (wstrb[2]) value[15: 8] <= wdata[23:16];

                if (wstrb[2:0]) begin
                    state <= STATE_TxH;
                    remaining <= 24;
                    counter <= 0;
                    din <= 1;
                end
            end

            case (state)
                STATE_IDLE: begin
                end
                STATE_TxH: begin
                    if ((counter + 1) >= (value[remaining - 1] ? T1H_DURATION : T0H_DURATION)) begin
                        state <= STATE_TxL;
                        counter <= 0;
                        din <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                STATE_TxL: begin
                    if ((counter + 1) >= (value[remaining - 1] ? T1L_DURATION : T0L_DURATION)) begin
                        counter <= 0;
                        if (remaining == 1) begin
                            state <= STATE_RESET;
                            din <= 0;
                        end else begin
                            remaining <= remaining - 1;
                            state <= STATE_TxH;
                            counter <= 0;
                            din <= 1;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end
                STATE_RESET: begin
                    if ((counter + 1) >= RES_DURATION) begin
                        state <= STATE_IDLE;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            endcase
        end
    end

endmodule
