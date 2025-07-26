module led_ctrl(
        input wire         clk,
        input wire         reset_n,
        input wire         leds_sel,
        input wire [5:0]   leds_data_i,
        input wire         we,
        output wire        leds_ready,
        output wire [31:0] leds_data_o
    );

    reg [5:0] leds = 'b0;

    assign leds_data_o = {26'b00000000000000000000000000, leds};
    assign leds_ready = leds_sel;

    always @(posedge clk or negedge reset_n)
        if(!reset_n)
            leds <= 'b0;
        else if(leds_sel)
            if(we)
                leds <= leds_data_i;

endmodule
