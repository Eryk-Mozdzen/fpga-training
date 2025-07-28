
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
        output wire         din
    );

    // assume that CASCADE_LENGTH = 1
    // rainbow
    // don't care about mcu control

    localparam T0H_DURATION = $rtoi(CLK_FREQ*0.40e-6 + 0.5);
    localparam T0L_DURATION = $rtoi(CLK_FREQ*0.85e-6 + 0.5);
    localparam T1H_DURATION = $rtoi(CLK_FREQ*0.80e-6 + 0.5);
    localparam T1L_DURATION = $rtoi(CLK_FREQ*0.45e-6 + 0.5);
    localparam RES_DURATION = $rtoi(CLK_FREQ*300e-6 + 0.5);

    localparam STATE_IDLE   = 3'b000;
    localparam STATE_T0H    = 3'b001;
    localparam STATE_T0L    = 3'b010;
    localparam STATE_T1H    = 3'b011;
    localparam STATE_T1L    = 3'b100;
    localparam STATE_RES    = 3'b101;

    reg [23:0]  value       = 0;
    reg [2:0]   state       = STATE_RES;
    reg [4:0]   bit_counter = 0;
    reg [31:0]  clk_counter = 0;

    reg [2:0]   color_state = 0;
    reg [7:0]   color_step  = 0;
    reg [31:0]  color_clk   = 0;

    always @(posedge clk) begin
        case (state)
            STATE_IDLE: begin
            end
            STATE_T0H: begin
                if (clk_counter >= T0H_DURATION) begin
                    clk_counter <= 'b0;
                    state <= STATE_T0L;
                end else begin
                    clk_counter <= clk_counter + 1;
                    din <= 1'b1;
                end
            end
            STATE_T0L: begin
                if (clk_counter >= T0L_DURATION) begin
                    clk_counter <= 'b0;
                    if (bit_counter >= 24) begin
                        bit_counter <= 'b0;
                        state <= STATE_RES;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        if (value[23 - bit_counter - 1]) begin
                            state <= STATE_T1H;
                        end else begin
                            state <= STATE_T0H;
                        end
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                    din <= 1'b0;
                end
            end
            STATE_T1H: begin
                if (clk_counter >= T1H_DURATION) begin
                    clk_counter <= 'b0;
                    state <= STATE_T1L;
                end else begin
                    clk_counter <= clk_counter + 1;
                    din <= 1'b1;
                end
            end
            STATE_T1L: begin
                if (clk_counter >= T1L_DURATION) begin
                    clk_counter <= 'b0;
                    if (bit_counter >= 24) begin
                        bit_counter <= 'b0;
                        state <= STATE_RES;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        if (value[23 - bit_counter - 1]) begin
                            state <= STATE_T1H;
                        end else begin
                            state <= STATE_T0H;
                        end
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                    din <= 1'b0;
                end
            end
            STATE_RES: begin
                if (clk_counter >= RES_DURATION) begin
                    clk_counter <= 'b0;
                    bit_counter <= 'b0;
                    if (value[23]) begin
                        state <= STATE_T1H;
                    end else begin
                        state <= STATE_T0H;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                    din <= 1'b0;

                    if (color_clk >= 105469) begin
                        color_clk <= 'b0;
                        if (color_step >= 255) begin
                            color_step <= 'b0;
                            if (color_state >= 5) begin
                                color_state <= 'b0;
                            end else begin
                                color_state <= color_state + 1;
                            end
                        end else begin
                            color_step <= color_step + 1;
                            case (color_state)
                                'h0: begin
                                    value[15:8]     <= 8'hFF;
                                    value[23:16]    <= color_step;
                                    value[7:0]      <= 8'h00;
                                end
                                'h1: begin
                                    value[15:8]     <= 8'hFF - color_step;
                                    value[23:16]    <= 8'hFF;
                                    value[7:0]      <= 8'h00;
                                end
                                'h2: begin
                                    value[15:8]     <= 8'h00;
                                    value[23:16]    <= 8'hFF;
                                    value[7:0]      <= color_step;
                                end
                                'h3: begin
                                    value[15:8]     <= 8'h00;
                                    value[23:16]    <= 8'hFF - color_step;
                                    value[7:0]      <= 8'hFF;
                                end
                                'h4: begin
                                    value[15:8]     <= color_step;
                                    value[23:16]    <= 8'h00;
                                    value[7:0]      <= 8'hFF;
                                end
                                'h5: begin
                                    value[15:8]     <= 8'hFF;
                                    value[23:16]    <= 8'h00;
                                    value[7:0]      <= 8'hFF - color_step;
                                end
                            endcase
                        end
                    end else begin
                        color_clk <= color_clk + 1;
                    end
                end
            end
        endcase
    end

    assign rdata = 32'h0;
    assign ready = 0;

endmodule
