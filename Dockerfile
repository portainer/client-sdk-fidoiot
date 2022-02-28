# see https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/linux.md

FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    python-setuptools \
    clang-format \
    dos2unix \
    ruby \
    libglib2.0-dev \
    libcap-dev \
    autoconf \
    libtool \
    libproxy-dev \
    libmozjs-52-0 \
    doxygen \
    cmake \
    libssl-dev \
    mercurial \
    make \
    gcc \
    wget \
    git \
    build-essential \
    xxd \
    httpie \
    uuid-runtime \
    iproute2 \
    default-jre \
 && rm -rf /var/lib/apt/lists/*

COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

WORKDIR /src/

# https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/linux.md#2-packages-requirements-when-executing-binaries
RUN wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz
RUN tar -zxf openssl-1.1.1k.tar.gz
WORKDIR /src/openssl-1.1.1k/
RUN ./config
RUN make
RUN make test
RUN mv /usr/bin/openssl /usr/bin/openssl.BACKUP
RUN make install
RUN ln -s /usr/local/bin/openssl /usr/bin/openssl
RUN ldconfig
RUN openssl version

# https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/linux.md#3-compiling-intel-safestringlib
WORKDIR /src/
RUN git clone --depth 1 -b v1.0.0 https://github.com/intel/safestringlib
WORKDIR /src/safestringlib/
RUN mkdir obj && make
ENV SAFESTRING_ROOT=/src/safestringlib

# https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/linux.md#4-compiling-intel-tinycbor
WORKDIR /src/
RUN git clone --depth 1 -b v0.5.3 https://github.com/intel/tinycbor
WORKDIR /src/tinycbor/
RUN make
ENV TINYCBOR_ROOT=/src/tinycbor

# https://github.com/secure-device-onboard/pri-fidoiot/tree/master/component-samples/demo#customize-for-multi-machine-setup
WORKDIR /src/
RUN git clone --depth 1 -b v1.0.2 https://github.com/secure-device-onboard/pri-fidoiot

# https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/linux.md#6-compiling-fdo-client-sdk

WORKDIR /src/client-sdk-fidoiot/
COPY . /src/client-sdk-fidoiot/
# https://github.com/secure-device-onboard/client-sdk-fidoiot/blob/master/docs/setup.md#6--fdo-credentials-reuse-protocol
RUN cmake -DREUSE=true
RUN make

