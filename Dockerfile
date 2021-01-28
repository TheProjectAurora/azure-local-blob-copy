FROM alpine:3.13.0

RUN set -xe && \
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
        rm -rf /tmp/azure-local-blob-copy