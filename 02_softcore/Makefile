TOP     = top
FAMILY  = GW2A-18C
DEVICE  = GW2AR-LV18QN88C8/I7
CST     = tangnano20k.cst
VERILOG = \
	src/top.v \
	src/reset_ctrl.v \
	picorv32/picorv32.v \
	src/uart_wrap.v \
	src/simpleuart.v \
	src/sram.v \
	src/gpio.v \
	src/ws2812b.v
TB = \
	ws2812b

SYNTH_JSON   = build/$(TOP)_synth.json
ROUTED_JSON  = build/$(TOP)_pnr.json
BITSTREAM    = build/$(TOP).fs

all: $(BITSTREAM)

build:
	mkdir -p build

$(SYNTH_JSON): build $(VERILOG)
	yosys -p "read_verilog $(VERILOG); synth_gowin -top $(TOP) -json $(SYNTH_JSON) -family gw2a"

$(ROUTED_JSON): $(SYNTH_JSON) $(CST)
	nextpnr-himbaechel --json $(SYNTH_JSON) --write $(ROUTED_JSON) --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CST)

$(BITSTREAM): $(ROUTED_JSON)
	gowin_pack -d $(FAMILY) -o $(BITSTREAM) $(ROUTED_JSON)

flash:
	openFPGALoader -b tangnano20k $(BITSTREAM)

clean:
	rm -rf build

tb: $(TB:%=build/%.vcd)

build/%.vcd: src/%.v src/tb/%_tb.v
	mkdir -p build
	iverilog -o build/$*_tb.out src/$*.v src/tb/$*_tb.v
	vvp build/$*_tb.out
	rm build/$*_tb.out
	mv $*_tb.vcd build

.PHONY: all clean flash tb
