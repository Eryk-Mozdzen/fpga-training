# FPGA training projects

- [x] basic project
- [ ] hard-core Cortex-M3 with custom peripheral
- [ ] soft-core RISC-V Linux with custom peripheral
- [ ] image generation
- [ ] camera image processing
- [ ] hardware accelerator for robotic's algorithm

### Building Docker

```bash
docker build -t fpga-training .
```

### Using Docker

```bash
docker run --rm --privileged -it -v /run/udev:/run/udev -v /dev:/dev -v "$PWD":/project -w /project fpga-training bash
```
