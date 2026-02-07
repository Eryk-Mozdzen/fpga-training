module pll (
    input wire  clk_in,
    output wire clk_out,
    output wire clk_outp
);

    wire pll_gnd;
    wire pll_lock;
    wire pll_reset;
    wire pll_clkoutd;
    wire pll_clkoutd3;

    assign pll_gnd = 0;

    rPLL #(
        .IDIV_SEL           (1),
        .FBDIV_SEL          (1),
        .ODIV_SEL           (32),
        .FCLKIN             ("27"),
        .DYN_IDIV_SEL       ("false"),
        .DYN_FBDIV_SEL      ("false"),
        .DYN_ODIV_SEL       ("false"),
        .PSDA_SEL           ("1010"),
        .DYN_DA_EN          ("false"),
        .DUTYDA_SEL         ("1000"),
        .CLKOUT_FT_DIR      (1),
        .CLKOUTP_FT_DIR     (1),
        .CLKOUT_DLY_STEP    (0),
        .CLKOUTP_DLY_STEP   (0),
        .CLKFB_SEL          ("internal"),
        .CLKOUT_BYPASS      ("false"),
        .CLKOUTP_BYPASS     ("false"),
        .CLKOUTD_BYPASS     ("false"),
        .DYN_SDIV_SEL       (2),
        .CLKOUTD_SRC        ("CLKOUT"),
        .CLKOUTD3_SRC       ("CLKOUT"),
        .DEVICE             ("GW2A-18C")
    ) pll (
        .CLKIN          (clk_in),
        .CLKOUT         (clk_out),
        .CLKOUTP        (clk_outp),
        .CLKOUTD        (pll_clkoutd),
        .CLKOUTD3       (pll_clkoutd3),
        .RESET          (pll_reset),
        .LOCK           (pll_lock),
        .RESET_P        (pll_gnd),
        .CLKFB          (pll_gnd),
        .FBDSEL         ({pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd}),
        .IDSEL          ({pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd}),
        .ODSEL          ({pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd, pll_gnd}),
        .PSDA           ({pll_gnd, pll_gnd, pll_gnd, pll_gnd}),
        .DUTYDA         ({pll_gnd, pll_gnd, pll_gnd, pll_gnd}),
        .FDLY           ({pll_gnd, pll_gnd, pll_gnd, pll_gnd})
    );

endmodule
