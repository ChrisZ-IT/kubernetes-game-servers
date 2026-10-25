FROM debian:stable-slim
ENV DEBIAN_FRONTEND noninteractive

RUN <<EOF
apt-get update && apt-get upgrade -y
apt-get install -y --no-install-recommends wine
apt-get autoremove -y && apt-get autoclean
rm -rf /var/lib/apt/lists/*
EOF

RUN useradd --no-log-init -u 1026 -g 100 -m -s /usr/sbin/nologin serviceuser

USER serviceuser
WORKDIR /data
