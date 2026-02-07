module sram #(
    parameter ADDR = 32'h0000_0000,
    parameter FILE = ""
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

    reg [31:0] memory [0:16383];

    initial begin
        if (FILE != "") begin
            $readmemh(FILE, memory);
        end
    end

    always @(posedge clk) begin
        if (mem_valid && ((mem_addr & 32'hFFFF_0000) == ADDR)) begin
            if (mem_wstrb[0]) memory[mem_addr[31:2] - ADDR[31:2]][ 7: 0] <= mem_wdata[ 7: 0];
            if (mem_wstrb[1]) memory[mem_addr[31:2] - ADDR[31:2]][15: 8] <= mem_wdata[15: 8];
            if (mem_wstrb[2]) memory[mem_addr[31:2] - ADDR[31:2]][23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3]) memory[mem_addr[31:2] - ADDR[31:2]][31:24] <= mem_wdata[31:24];
        end

        mem_rdata <= memory[mem_addr[31:2] - ADDR[31:2]];
        mem_ready <= mem_valid && !mem_ready && ((mem_addr & 32'hFFFF_0000) == ADDR);
    end

endmodule
