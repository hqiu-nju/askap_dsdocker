FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Base system tools, Python, and WSClean build dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    wget \
    gnupg \
    build-essential \
    cmake \
    pkg-config \
    g++ \
    make \
    libfftw3-dev \
    libcfitsio-dev \
    libboost-all-dev \
    libgsl-dev \
    libhdf5-dev \
    liblua5.3-dev \
    casacore-dev \
    libaocommon-dev \
    python3 \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install MIRIAD from Ubuntu packages
RUN apt-get update \
    && apt-get install -y miriad \
    && rm -rf /var/lib/apt/lists/*

# Build and install WSClean from source
RUN git clone --depth 1 https://gitlab.com/aroffringa/wsclean.git /tmp/wsclean \
    && cmake -S /tmp/wsclean -B /tmp/wsclean/build \
    && cmake --build /tmp/wsclean/build -j"$(nproc)" \
    && cmake --install /tmp/wsclean/build \
    && rm -rf /tmp/wsclean

# Install dstools
RUN pip install radio-dstools

# Set working directory
WORKDIR /workspace

# Set default command
CMD ["/bin/bash"]
