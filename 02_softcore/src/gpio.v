module gpio #(
    parameter WIDTH = 8
) (
    input wire              clk,
    input wire              reset_n,
    input wire              sel,
    input wire [WIDTH-1:0]  wdata,
    input wire              wstrb,
    output wire             ready,
    output wire [31:0]      rdata
);

    reg [WIDTH-1:0] state = 'b0;

    assign rdata = {(32-WIDTH)'b0, state};
    assign ready = sel;

    always @(posedge clk or negedge reset_n)
        if(!reset_n)
            state <= 'b0;
        else if(sel)
            if(wstrb)
                state <= wdata;

endmodule
