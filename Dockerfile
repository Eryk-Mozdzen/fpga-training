FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install --no-install-recommends -y \
        python3 \
        python3-dev \
        python3-pip \
        libeigen3-dev \
        build-essential \
        git \
        wget \
        bison \
        flex \
        pkg-config \
        tcl-dev \
        tclsh \
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
