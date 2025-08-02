module reset_ctrl (
    input wire  clk,
    input wire  reset_button,
    output wire resetn
);

    reg [5:0] reset_count = 0;

    assign resetn = &reset_count;

    always @(posedge clk)
        if(reset_button)
            reset_count <= 'b0;
        else
            reset_count <= reset_count + !resetn;

endmodule
