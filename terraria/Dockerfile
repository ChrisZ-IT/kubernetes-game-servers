FROM debian:stable-slim

RUN <<EOF
apt-get update && apt-get upgrade -y
apt-get install -y --no-install-recommends curl unzip ca-certificates jq
rm -rf /var/lib/apt/lists/*
EOF

RUN useradd --no-log-init -u 1026 -g 100 -m -s /bin/bash serviceuser

WORKDIR /home/serviceuser

RUN chown -R 1026:100 /home/serviceuser

USER 1026:100
