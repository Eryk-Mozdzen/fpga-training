module gpio (
    input wire              clk,
    input wire              resetn,
    input wire              sel,
    input wire [15:0]       addr,
    input wire [3:0]        wstrb,
    input wire [31:0]       wdata,
    output wire [31:0]      rdata,
    output wire             ready
);

    reg [31:0] state = 0;

    assign rdata = state;
    assign ready = sel;

    always @(posedge clk or negedge resetn) begin
        if(!resetn) begin
            state <= 0;
        end else if(sel) begin
            if (wstrb[0]) state[ 7: 0] <= wdata[ 7: 0];
            if (wstrb[1]) state[15: 8] <= wdata[15: 8];
            if (wstrb[2]) state[23:16] <= wdata[23:16];
            if (wstrb[3]) state[31:24] <= wdata[31:24];
        end
    end

endmodule
