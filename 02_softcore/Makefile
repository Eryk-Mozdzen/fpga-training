FAMILY  = GW2A-18C
DEVICE  = GW2AR-LV18QN88C8/I7
CST     = tangnano20k.cst

SRC = \
	src/top.v \
	src/reset_ctrl.v \
	picorv32/picorv32.v \
	src/sram.v \
	src/gpio.v \
	src/uart.v \
	src/ws2812b.v

TESTBENCH = \
	src/tb/top_tb.v \
	src/tb/uart_tb.v \
	src/tb/ws2812b_tb.v

TB_NAMES = $(basename $(notdir $(TESTBENCH)))
TB_TARGETS = $(TB_NAMES:%=build/%.vcd)

TOP     	 = top
SYNTH_JSON   = build/$(TOP)_synth.json
ROUTED_JSON  = build/$(TOP)_pnr.json
BITSTREAM    = build/$(TOP).fs

all: $(BITSTREAM)

$(SYNTH_JSON): $(SRC)
	mkdir -p build
	yosys -p "read_verilog $(SRC); synth_gowin -top $(TOP) -json $(SYNTH_JSON) -family gw2a"

$(ROUTED_JSON): $(SYNTH_JSON) $(CST)
	nextpnr-himbaechel --json $(SYNTH_JSON) --write $(ROUTED_JSON) --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CST)

$(BITSTREAM): $(ROUTED_JSON)
	gowin_pack -d $(FAMILY) -o $(BITSTREAM) $(ROUTED_JSON)

flash:
	openFPGALoader -b tangnano20k $(BITSTREAM)

clean:
	rm -rf build

tb: $(TB_TARGETS)

define TB_template
build/$(basename $(notdir $(1))).vcd: $(1) $(SRC)
	mkdir -p build
	iverilog -o build/$(basename $(notdir $(1))).out $(SRC) $(1)
	vvp build/$(basename $(notdir $(1))).out
	rm build/$(basename $(notdir $(1))).out
	mv $(basename $(notdir $(1))).vcd build/
endef

$(foreach tb,$(TESTBENCH),$(eval $(call TB_template,$(tb))))

.PHONY: all clean flash tb
