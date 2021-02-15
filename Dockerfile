FROM alpine:latest

ARG USER=notroot
ARG GROUP=notroot
ARG UID=1000
ARG GID=1000

COPY requirements.txt /tmp/requirements.txt

#BUILD FAIL SO THAT WHY...
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
# ....ERROR:
######################
#---clip---
#  running build_rust
#
#      =============================DEBUG ASSISTANCE=============================
#      If you are seeing a compilation error please try the following steps to
#      successfully install cryptography:
#      1) Upgrade to the latest pip and try again. This will fix errors for most
#         users. See: https://pip.pypa.io/en/stable/installing/#upgrading-pip
#      2) Read https://cryptography.io/en/latest/installation.html for specific
#         instructions for your platform.
#      3) Check our frequently asked questions for more information:
#         https://cryptography.io/en/latest/faq.html
#      4) Ensure you have a recent Rust toolchain installed:
#         https://cryptography.io/en/latest/installation.html#rust
#      5) If you are experiencing issues with Rust for *this release only* you may
#         set the environment variable `CRYPTOGRAPHY_DONT_BUILD_RUST=1`.
#      =============================DEBUG ASSISTANCE=============================
#
#  error: Can not find Rust compiler
#  ----------------------------------------
#  ERROR: Failed building wheel for cryptography
#Failed to build cryptography
#ERROR: Could not build wheels for cryptography which use PEP 517 and cannot be installed directly
#---clap---

RUN set -xe && \
    echo $(echo BUILD_TIME_ALPINE_VERSION: && /bin/cat /etc/alpine-release) && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        git \
        python3 \
        py3-pip && \
    apk add --no-cache \ 
        gcc \
        python3-dev \
        musl-dev \ 
        libffi-dev \ 
        libressl-dev && \
    pip install -r /tmp/requirements.txt &&\
    apk del \
        git \    
        gcc \
        python3-dev \
        musl-dev \
        libffi-dev \
        libressl-dev && \
    addgroup -g ${GID} -S ${GROUP} && \
    adduser -u ${UID} -S -D ${USER} ${GROUP}

COPY --chown=${USER} src/ /app/
WORKDIR /app
USER ${USER}
RUN chmod +x /app/azure-copy-tool.py

ENTRYPOINT echo $(echo ALPINE_VERSION: && /bin/cat /etc/alpine-release) && \
           /usr/bin/python3 /app/azure-copy-tool.py