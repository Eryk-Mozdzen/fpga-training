TOP     = project
DEVICE  = GW2AR-LV18QN88C8/I7
VERILOG = src/project.v
CST     = project.cst

SYNTH_JSON   = build/$(TOP).json
ROUTED_JSON  = build/$(TOP)_pnr.json
BITSTREAM    = build/$(TOP).fs

all: $(BITSTREAM)

build:
	mkdir -p build

$(SYNTH_JSON): build $(VERILOG)
	yosys -p "read_verilog $(VERILOG); synth_gowin -top $(TOP) -json $(SYNTH_JSON)"

$(ROUTED_JSON): $(SYNTH_JSON) $(CST)
	nextpnr-gowin --json $(SYNTH_JSON) --write $(ROUTED_JSON) --device $(DEVICE) --cst $(CST)

$(BITSTREAM): $(ROUTED_JSON)
	gowin_pack -d $(DEVICE) -o $(BITSTREAM) $(ROUTED_JSON)

flash: $(BITSTREAM)
	openFPGALoader -b tangnano20k $(BITSTREAM)

clean:
	rm -rf build

.PHONY: all clean flash
