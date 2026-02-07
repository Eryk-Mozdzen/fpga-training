module pll (
    input wire  clk_in,
    output wire clk_out,
    output wire clk_outp
);

    assign clk_out  = clk_in;
    assign clk_outp = ~clk_in;

endmodule
