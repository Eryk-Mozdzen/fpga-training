module gpio #(
    parameter ADDR = 32'h0000_0000
) (
    input wire          clk,
    input wire          resetn,
    input wire          mem_valid,
    input wire [31:0]   mem_addr,
    input wire [3:0]    mem_wstrb,
    input wire [31:0]   mem_wdata,
    output reg [31:0]   mem_rdata,
    output reg          mem_ready
);

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            mem_rdata <= 0;
            mem_ready <= 0;
        end else begin
            mem_ready <= 0;

            if (mem_valid && ((mem_addr & 32'hFFFF_FFFF) == ADDR)) begin
                if (|mem_wstrb) begin
                    if (mem_wstrb[0]) mem_rdata[ 7: 0] <= mem_wdata[ 7: 0];
                    if (mem_wstrb[1]) mem_rdata[15: 8] <= mem_wdata[15: 8];
                    if (mem_wstrb[2]) mem_rdata[23:16] <= mem_wdata[23:16];
                    if (mem_wstrb[3]) mem_rdata[31:24] <= mem_wdata[31:24];
                    mem_ready <= 1;
                end else begin
                    mem_ready <= 1;
                end
            end
        end
    end

endmodule
