FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install --no-install-recommends -y \
        python3 \
        python3-dev \
        python3-pip \
        libeigen3-dev \
        build-essential \
        automake \
        autoconf \
        libtool \
        git \
        wget \
        bison \
        flex \
        pkg-config \
        tcl-dev \
        tclsh \
        gperf \
        gawk \
        desktop-file-utils \
        libgtk-3-dev \
        tcl-dev \
        tk-dev \
        libgtk2.0-dev \
        libbz2-dev \
        libjudy-dev \
        libgirepository1.0-dev \
        libffi-dev \
        libftdi1-dev \
        libusb-1.0-0-dev \
        libreadline-dev \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-iostreams-dev \
        ca-certificates \
    && update-ca-certificates \
    && pip3 install \
        apycula==0.17.0 \
        pybind11

RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.sh \
    && chmod +x cmake-3.31.8-linux-x86_64.sh \
    && ./cmake-3.31.8-linux-x86_64.sh --skip-license --prefix=/usr/local \
    && rm cmake-3.31.8-linux-x86_64.sh

RUN wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2025.07.16/riscv32-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz \
    && tar -xf riscv32-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz \
    && rm riscv32-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz

ENV PATH="$PATH:/riscv/bin"

RUN git clone --depth 1 --branch v0.55 --recursive https://github.com/YosysHQ/yosys.git \
    && cd yosys \
    && make -j6 \
    && make install

RUN git clone --depth 1 --branch nextpnr-0.8 --recursive https://github.com/YosysHQ/nextpnr.git \
    && cd nextpnr \
    && mkdir -p build \
    && cd build \
    && cmake -DARCH="himbaechel" -DHIMBAECHEL_UARCH="gowin" .. \
    && make -j6 \
    && make install

RUN git clone --depth 1 --branch v0.13.1 --recursive https://github.com/trabucayre/openFPGALoader \
    && cd openFPGALoader \
    && mkdir -p build \
    && cd build \
    && cmake .. \
    && make -j6 \
    && make install \
    && mkdir -p /etc/udev/rules.d \
    && cp ../99-openfpgaloader.rules /etc/udev/rules.d/

RUN git clone --depth 1 --branch v3.3.116 --recursive https://github.com/gtkwave/gtkwave.git \
    && cd gtkwave/gtkwave3-gtk3 \
    && ./autogen.sh \
    && ./configure --enable-gtk3 \
    && make -j6 \
    && make install

RUN git clone --depth 1 --branch v12_0 --recursive https://github.com/steveicarus/iverilog.git \
    && cd iverilog \
    && sh autoconf.sh \
    && ./configure \
    && make -j6 \
    && make install
