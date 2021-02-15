FROM alpine:latest

ARG USER=notroot
ARG GROUP=notroot
ARG UID=1000
ARG GID=1000

COPY requirements.txt /tmp/requirements.txt
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

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

COPY --chown=${USER} src/azure-copy-tool.py /azure-copy-tool.py
WORKDIR /home/${USER}
USER ${USER}
RUN chmod +x /azure-copy-tool.py

ENTRYPOINT echo $(echo ALPINE_VERSION: && /bin/cat /etc/alpine-release) && \
           /usr/bin/python3 /azure-copy-tool.py