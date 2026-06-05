FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    wget \
    curl \
    git \
    build-essential \
    libboost-all-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libgsl-dev \
    libhdf5-dev \
    liblua5.3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install WSclean (version 3.5+)
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:kernsuite/kern-9 \
    && apt-get update \
    && apt-get install -y wsclean \
    && rm -rf /var/lib/apt/lists/*

# Install MIRIAD (for ATCA pre-processing)
RUN apt-get update && apt-get install -y \
    miriad \
    || echo "MIRIAD installation optional - install manually if needed" \
    && rm -rf /var/lib/apt/lists/*

# Install dstools
RUN pip install radio-dstools

# Set working directory
WORKDIR /workspace

# Set default command
CMD ["/bin/bash"]