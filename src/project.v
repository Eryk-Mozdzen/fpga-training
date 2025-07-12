module project (
    input wire key_i,
    input wire rst_i,
    output wire [5:0] led
);

    assign led[0] = ~key_i;
    assign led[1] = ~rst_i;
    assign led[2] = ~(key_i & rst_i);
    assign led[3] = ~(key_i | rst_i);
    assign led[4] = 1;
    assign led[5] = 1;

endmodule
