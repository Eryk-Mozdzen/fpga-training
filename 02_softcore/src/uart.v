module uart_transmitter #(
    parameter DATA_BITS = 8,
    parameter STOP_DURATION = 1,
    parameter BIT_DURATION = 1
) (
    input wire                  clk,
    input wire                  resetn,
    input wire [DATA_BITS-1:0]  data,
    input wire                  data_valid,
    output reg                  data_req,
    output reg                  tx
);

    localparam STATE_IDLE   = 2'b00;
    localparam STATE_START  = 2'b01;
    localparam STATE_DATA   = 2'b10;
    localparam STATE_STOP   = 2'b11;

    reg [1:0]           state;
    reg [DATA_BITS-1:0] data_latched;
    reg [31:0]          clk_counter;
    reg [3:0]           bit_counter;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= STATE_IDLE;
            data_req <= 1;
            tx <= 1;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (data_valid) begin
                        state <= STATE_START;
                        data_latched <= data;
                        data_req <= 0;
                        clk_counter <= 0;
                        tx <= 0;
                    end
                end
                STATE_START: begin
                    if ((clk_counter + 1) >= BIT_DURATION) begin
                        state <= STATE_DATA;
                        clk_counter <= 0;
                        bit_counter <= 1;
                        tx <= data_latched[0];
                    end else begin
                        clk_counter <= clk_counter + 1;
                    end
                end
                STATE_DATA: begin
                    if ((clk_counter + 1) >= BIT_DURATION) begin
                        clk_counter <= 0;
                        if (bit_counter >= DATA_BITS) begin
                            state <= STATE_STOP;
                            tx <= 1;
                        end else begin
                            bit_counter <= bit_counter + 1;
                            tx <= data_latched[bit_counter];
                        end
                    end else begin
                        clk_counter <= clk_counter + 1;
                    end
                end
                STATE_STOP: begin
                    if ((clk_counter + 1) >= STOP_DURATION) begin
                        if (data_valid) begin
                            data_latched <= data;
                            state <= STATE_START;
                            data_req <= 0;
                            clk_counter <= 0;
                            tx <= 0;
                        end else begin
                            state <= STATE_IDLE;
                            data_req <= 1;
                        end
                    end else begin
                        if (((clk_counter + 2) >= STOP_DURATION) && data_valid)
                            data_req <= 1;

                        clk_counter <= clk_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule

module uart_receiver #(
    parameter DATA_BITS = 8,
    parameter STOP_DURATION = 1,
    parameter BIT_DURATION = 1
) (
    input wire                  clk,
    input wire                  resetn,
    input wire                  rx,
    output reg [DATA_BITS-1:0]  data,
    output reg                  data_valid,
    input wire                  data_ack
);

    localparam STATE_IDLE   = 2'b00;
    localparam STATE_START  = 2'b01;
    localparam STATE_DATA   = 2'b10;
    localparam STATE_STOP   = 2'b11;

    reg [1:0]           state;
    reg [DATA_BITS-1:0] data_buffer;
    reg [31:0]          clk_counter;
    reg [3:0]           bit_counter;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= STATE_IDLE;
            data <= 0;
            data_buffer <= 0;
            data_valid <= 0;
        end else begin
            if (data_valid && data_ack) begin
                data_valid <= 0;
            end

            case (state)
                STATE_IDLE: begin
                    if (!rx) begin
                        state <= STATE_START;
                        clk_counter <= 0;
                    end
                end
                STATE_START: begin
                    if ((clk_counter + 1) >= (BIT_DURATION/2)) begin
                        if (!rx) begin
                            state <= STATE_DATA;
                            clk_counter <= 0;
                            bit_counter <= 0;
                            data_buffer <= 0;
                        end else begin
                            state <= STATE_IDLE;
                        end
                    end else begin
                        clk_counter <= clk_counter + 1;
                    end
                end
                STATE_DATA: begin
                    if ((clk_counter + 1) >= BIT_DURATION) begin
                        clk_counter <= 0;
                        data_buffer[bit_counter] <= rx;
                        bit_counter <= bit_counter + 1;

                        if ((bit_counter + 1) >= DATA_BITS) begin
                            state <= STATE_STOP;
                            clk_counter <= 0;
                        end
                    end else begin
                        clk_counter <= clk_counter + 1;
                    end
                end
                STATE_STOP: begin
                    state <= STATE_IDLE;
                    data <= data_buffer;
                    data_valid <= 1;
                end
            endcase
        end
    end

endmodule

module uart #(
    parameter ADDR = 32'h0000_0000,
    parameter CLK_FREQ = 1e6,
    parameter BAUDRATE = 115200,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
) (
    input wire          clk,
    input wire          resetn,
    input wire          mem_valid,
    input wire [31:0]   mem_addr,
    input wire [3:0]    mem_wstrb,
    input wire [31:0]   mem_wdata,
    output reg [31:0]   mem_rdata,
    output reg          mem_ready,
    output wire         tx,
    input wire          rx
);

    localparam BIT_DURATION     = $rtoi(CLK_FREQ/BAUDRATE + 0.5);
    localparam STOP_DURATION    = $rtoi(STOP_BITS*BIT_DURATION + 0.5);

    wire                    select;
    wire [7:0]              address;
    wire                    write;
    wire                    tx_ready;
    wire [DATA_BITS-1:0]    rx_data;
    wire                    rx_ready;
    reg                     rx_ack;

    assign select = mem_valid && ((mem_addr & 32'hFFFF_FF00) == ADDR);
    assign address = mem_addr & 32'h0000_00FF;
    assign write = |mem_wstrb;

    uart_transmitter #(
        .DATA_BITS      (DATA_BITS),
        .STOP_DURATION  (STOP_DURATION),
        .BIT_DURATION   (BIT_DURATION)
    ) transmitter (
        .clk            (clk),
        .resetn         (resetn),
        .data           (mem_wdata[DATA_BITS-1:0]),
        .data_valid     (select && write && (address == 8'h04)),
        .data_req       (tx_ready),
        .tx             (tx)
    );

    uart_receiver #(
        .DATA_BITS      (DATA_BITS),
        .STOP_DURATION  (STOP_DURATION),
        .BIT_DURATION   (BIT_DURATION)
    ) receiver (
        .clk            (clk),
        .resetn         (resetn),
        .data           (rx_data),
        .data_valid     (rx_ready),
        .data_ack       (rx_ack),
        .rx             (rx)
    );

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            mem_rdata <= 0;
            mem_ready <= 0;
            rx_ack <= 0;
        end else begin
            mem_rdata <= 0;
            mem_ready <= 0;

            if (!rx_ready && rx_ack)
                rx_ack <= 0;

            if (select) begin
                if (write) begin
                    case (address)
                        8'h00: begin
                            mem_ready <= 1;
                        end
                        8'h04: begin
                            mem_ready <= 1;
                        end
                        8'h08: begin
                            mem_ready <= 1;
                        end
                    endcase
                end else begin
                    case (address)
                        8'h00: begin
                            mem_rdata <= {30'h0, rx_ready, tx_ready};
                            mem_ready <= 1;
                        end
                        8'h04: begin
                            mem_rdata <= 0;
                            mem_ready <= 1;
                        end
                        8'h08: begin
                            mem_rdata <= 0;
                            mem_rdata[DATA_BITS-1:0] <= rx_data;
                            mem_ready <= 1;
                            rx_ack <= 1;
                        end
                    endcase
                end
            end
        end
    end

endmodule
