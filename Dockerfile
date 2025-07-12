FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install --no-install-recommends -y \
        python3 \
        build-essential \
        git \
        cmake \
        bison \
        flex \
        pkg-config \
        tcl-dev \
        tclsh \
        libffi-dev \
        libreadline-dev \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        ca-certificates

RUN update-ca-certificates

RUN git clone --depth 1 --branch v0.55 --recursive https://github.com/YosysHQ/yosys.git \
    && cd yosys \
    && make \
    && make install

RUN git clone --depth 1 --branch nextpnr-0.8 --recursive https://github.com/YosysHQ/nextpnr.git \
    && cd nextpnr \
    && mkdir -p build \
    && cd build \
    && cmake -DARCH="himbaechel" -DHIMBAECHEL_UARCH="gowin" .. \
    && make \
    && make install

RUN git clone --depth 1 --branch v0.13.1 --recursive https://github.com/trabucayre/openFPGALoader \
    && cd openFPGALoader \
    && mkdir -p build \
    && cd build \
    && cmake .. \
    && make \
    && make install

WORKDIR /
