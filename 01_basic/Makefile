DOCKER_IMG = emozdzen/fpga-utils
DOCKER_CMD = docker run --rm --privileged -v $(PWD):/project -w /project $(DOCKER_IMG)

TOP     = project
FAMILY  = GW2A-18C
DEVICE  = GW2AR-LV18QN88C8/I7
VERILOG = src/project.v
CST     = tangnano20k.cst

SYNTH_JSON   = build/$(TOP)_synth.json
ROUTED_JSON  = build/$(TOP)_pnr.json
BITSTREAM    = build/$(TOP).fs

all: $(BITSTREAM)

build:
	mkdir -p build

$(SYNTH_JSON): build $(VERILOG)
	$(DOCKER_CMD) yosys -p "read_verilog $(VERILOG); synth_gowin -top $(TOP) -json $(SYNTH_JSON) -family gw2a"

$(ROUTED_JSON): $(SYNTH_JSON) $(CST)
	$(DOCKER_CMD) nextpnr-himbaechel --json $(SYNTH_JSON) --write $(ROUTED_JSON) --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CST)

$(BITSTREAM): $(ROUTED_JSON)
	$(DOCKER_CMD) gowin_pack -d $(FAMILY) -o $(BITSTREAM) $(ROUTED_JSON)

flash:
	$(DOCKER_CMD) openFPGALoader -b tangnano20k $(BITSTREAM)

clean:
	rm -rf build

.PHONY: all clean flash
