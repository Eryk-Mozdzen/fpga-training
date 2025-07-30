# FPGA training projects

- [x] basic project
- [ ] hard-core Cortex-M3 with custom peripheral
- [ ] soft-core RISC-V Linux with custom peripheral
- [ ] image generation
- [ ] camera image processing
- [ ] hardware accelerator for robotic's algorithm

### Build Docker

```bash
docker build -t fpga-training .
```

### Enter Docker

```bash
docker run \
    --rm \
    --privileged \
    -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /run/udev:/run/udev \
    -v /dev:/dev \
    -v "$PWD":/project \
    -w /project \
    fpga-training
```
