
// offset       name        fields
// 0x00000000   STATUS  R   NNNNNNNNNNNNNNNNxxxxxxxxxxxxxxxC
// 0x00000004   CTRL    W   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxW
// 0x00000008   LED0    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB
// 0x0000000C   LED1    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB
// ...          ...     ..  ...
// ...          LEDn    RW  xxxxxxxxRRRRRRRRGGGGGGGGBBBBBBBB

module ws2812b #(
        parameter MAX_CASCADE_LENGTH = 1
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

    assign rdata = 32'h0;
    assign ready = 0;
    assign din = 0;

endmodule
