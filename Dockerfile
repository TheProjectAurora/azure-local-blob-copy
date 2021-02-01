FROM alpine:latest

ARG USER=notroot
ARG GROUP=notroot
ARG UID=1000
ARG GID=1000

RUN set -xe && \
    echo $(echo BUILD_TIME_ALPINE_VERSION: && /bin/cat /etc/alpine-release) && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        git \
        python3 \
        py3-pip && \
    cd /tmp && git clone https://github.com/TheProjectAurora/azure-local-blob-copy.git &&\
    cp /tmp/azure-local-blob-copy/src/azure-copy-tool.py /usr/bin/azure-copy-tool.py && \
    chmod a+rx /usr/bin/azure-copy-tool.py && \
    apk add --no-cache \ 
        gcc \
        python3-dev \
        musl-dev \ 
        libffi-dev \ 
        libressl-dev &&\
    cd /tmp/azure-local-blob-copy && pip install -r requirements.txt &&\
    apk del \
        git \    
        gcc \
        python3-dev \
        musl-dev \
        libffi-dev \
        libressl-dev && \
    rm -rf /tmp/azure-local-blob-copy && \
    addgroup -g ${GID} -S ${GROUP} && \
    adduser -u ${UID} -S -D ${USER} ${GROUP}

COPY --chown=${USER} src/azure-copy-tool.py /azure-copy-tool.py
WORKDIR /home/${USER}
USER ${USER}
RUN chmod +x /azure-copy-tool.py

ENTRYPOINT echo $(echo ALPINE_VERSION: && /bin/cat /etc/alpine-release) && /usr/bin/python3 /azure-copy-tool.py