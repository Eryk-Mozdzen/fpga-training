module reset_ctrl (
    input wire  clk,
    input wire  reset_button,
    output wire reset_n
);

    reg [5:0] reset_count = 0;

    assign reset_n = &reset_count;

    always @(posedge clk)
        if(reset_button)
            reset_count <= 'b0;
        else
            reset_count <= reset_count + !reset_n;

endmodule
