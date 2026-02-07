module reset (
    input wire  clk,
    input wire  button,
    output wire resetn
);

    reg [5:0] counter = 0;

    assign resetn = &counter;

    always @(posedge clk) begin
        if(button) begin
            counter <= 0;
        end else if(!resetn) begin
            counter <= counter + 1;
        end
    end

endmodule
