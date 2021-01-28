FROM alpine:3.13.0

RUN apk add git python3 py3-pip && \
    cd /tmp && git clone https://github.com/TheProjectAurora/azure-local-blob-copy.git && \
    cd azure-local-blob-copy && \
    pip install -r requirements.txt
