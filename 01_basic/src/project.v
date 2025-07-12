module project (
    input wire key_i,
    input wire rst_i,
    output wire [5:0] led
);

    assign led[0] = ~(key_i & rst_i);
    assign led[1] = 1;
    assign led[2] = 1;
    assign led[3] = 1;
    assign led[4] = 1;
    assign led[5] = ~(key_i | rst_i);

endmodule
