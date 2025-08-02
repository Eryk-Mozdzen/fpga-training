module sram #(
    parameter BYTES = 65536,
    parameter FILE = ""
) (
    input wire          clk,
    input wire          resetn,
    input wire          sel,
    input wire [31:0]   addr,
    input wire [3:0]    wstrb,
    input wire [31:0]   wdata,
    output reg [31:0]   rdata,
    output reg          ready
);

    reg [31:0] mem [((BYTES/4) - 1):0];

    initial begin
        if (FILE != "") begin
            $readmemh(FILE, mem);
        end
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            rdata <= 0;
        end else if (sel && (wstrb == 4'b0000)) begin
            rdata <= mem[addr[31:2]];
        end
    end

    always @(posedge clk) begin
        if (sel) begin
            ready <= 1;
            if (wstrb[0]) mem[addr[31:2]][ 7: 0] <= wdata[ 7: 0];
            if (wstrb[1]) mem[addr[31:2]][15: 8] <= wdata[15: 8];
            if (wstrb[2]) mem[addr[31:2]][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[addr[31:2]][31:24] <= wdata[31:24];
        end else begin
            ready <= 0;
        end
    end

endmodule
