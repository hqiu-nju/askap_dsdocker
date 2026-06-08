ARG KERN_PLATFORM=linux/amd64
FROM --platform=${KERN_PLATFORM} kernsuite/base:10

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG MIRIAD_VERSION=2026.04.30
ARG EVERYBEAM_REPOSITORY=https://git.astron.nl/RD/EveryBeam.git
ARG WSCLEAN_VERSION=v3.7
ARG WSCLEAN_REPOSITORY=https://gitlab.com/aroffringa/wsclean.git

# System utilities and Python runtime used for interactive ASKAP reductions.
RUN docker-apt-install \
    bash-completion \
    bison \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    flex \
    gfortran \
    git \
    less \
    libblas-dev \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-python-dev \
    libboost-test-dev \
    libcfitsio-dev \
    libfftw3-dev \
    libgsl-dev \
    libgtkmm-3.0-dev \
    libhdf5-dev \
    liblapack-dev \
    libncurses-dev \
    libopenmpi-dev \
    libpng-dev \
    libpython3-dev \
    libreadline-dev \
    libxml2-dev \
    libx11-dev \
    make \
    nano \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    vim \
    wget

# KERN Suite radio astronomy tools.
RUN docker-apt-install \
    aoflagger \
    casacore-dev \
    casacore-data \
    casacore-tools \
    python3-casacore \
    wcslib-dev

# Build and install EveryBeam from source, following the upstream build guide.
RUN git clone --recursive -j4 "${EVERYBEAM_REPOSITORY}" /tmp/EveryBeam \
    && cmake -S /tmp/EveryBeam -B /tmp/EveryBeam/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/everybeam \
        -DCMAKE_CXX_FLAGS_RELEASE='-O3 -DNDEBUG -fno-lto' \
        -DCMAKE_SHARED_LINKER_FLAGS='-fno-lto' \
        -DBUILD_TESTING=OFF \
        -DBUILD_WITH_PYTHON=ON \
        -DPORTABLE=ON \
    && cmake --build /tmp/EveryBeam/build --target install --parallel "$(nproc)" \
    && printf '/opt/everybeam/lib\n' > /etc/ld.so.conf.d/everybeam.conf \
    && ldconfig \
    && PYTHONPATH=/opt/everybeam/lib/python3.12/dist-packages python3 -c 'import everybeam' \
    && rm -rf /tmp/EveryBeam

ENV EVERYBEAM_ROOT=/opt/everybeam
ENV LD_LIBRARY_PATH=/opt/everybeam/lib
ENV PYTHONPATH=/opt/everybeam/lib/python3.12/dist-packages

# Build WSClean after EveryBeam so primary-beam correction is enabled.
RUN docker-apt-install \
    pybind11-dev

RUN git clone --depth 1 --branch "${WSCLEAN_VERSION}" "${WSCLEAN_REPOSITORY}" /tmp/wsclean \
    && cmake -S /tmp/wsclean -B /tmp/wsclean/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_PREFIX_PATH=/opt/everybeam \
        -DPORTABLE=ON \
    && cmake --build /tmp/wsclean/build --target install --parallel "$(nproc)" \
    && wsclean --version \
    && rm -rf /tmp/wsclean

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
RUN docker-apt-install \
    python3-astropy \
    python3-click \
    python3-colorlog \
    python3-h5py \
    python3-matplotlib \
    python3-pandas \
    python3-scipy

RUN python3 -m pip install --no-cache-dir --break-system-packages --no-deps \
    radio-dstools

WORKDIR /workspace

CMD ["/bin/bash"]
