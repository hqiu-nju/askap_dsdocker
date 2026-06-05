ARG KERN_PLATFORM=linux/amd64
FROM --platform=${KERN_PLATFORM} kernsuite/base:9

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG MIRIAD_VERSION=2026.04.30

# System utilities and Python runtime used for interactive ASKAP reductions.
RUN docker-apt-install \
    bash-completion \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    gfortran \
    git \
    less \
    libcfitsio-dev \
    nano \
    libpng-dev \
    libreadline-dev \
    libx11-dev \
    python3 \
    python3-dev \
    python3-pip \
    vim \
    wget

# KERN Suite radio astronomy tools.
RUN docker-apt-install \
    aoflagger \
    casacore-data \
    casacore-tools \
    python3-casacore \
    wsclean

# Build and install CSIRO MIRIAD in the same container.
RUN git clone --depth 1 --branch "${MIRIAD_VERSION}" https://github.com/csiro/miriad.git /tmp/miriad \
    && sed -i '/DOWNLOAD_EXTRACT_TIMESTAMP/d' \
        /tmp/miriad/pgplot/CMakeLists.txt \
        /tmp/miriad/rpfits/CMakeLists.txt \
        /tmp/miriad/wcslib/CMakeLists.txt \
    && cmake -S /tmp/miriad -B /tmp/miriad/build -DCMAKE_INSTALL_PREFIX=/opt/miriad \
    && cmake --build /tmp/miriad/build --target install --parallel 1 \
    && . /opt/miriad/MIRRC.sh \
    && command -v miriad \
    && rm -rf /tmp/miriad

ENV MIR=/opt/miriad
ENV PATH="/opt/miriad/bin:/opt/miriad/linux64/bin:${PATH}"

RUN printf '\n. /opt/miriad/MIRRC.sh\n' >> /etc/bash.bashrc

# Python tooling used by the ASKAP dynamic spectrum workflow.
RUN python3 -m pip install --no-cache-dir \
    radio-dstools

WORKDIR /workspace

CMD ["/bin/bash"]
