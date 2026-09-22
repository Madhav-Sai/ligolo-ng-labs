# Stand-in "Kali" attack box for the lab.
#
# We use debian:bookworm-slim instead of the real kalilinux/kali-rolling image to keep
# the lab fast to build and reproducible offline once cached. Everything taught here
# (the ligolo-ng proxy binary, nmap, curl) behaves identically on real Kali. If you
# want the real thing, change the FROM line below to kalilinux/kali-rolling and
# `apt install -y ligolo-ng nmap curl iproute2` instead.
FROM debian:bookworm-slim

ARG LIGOLO_VERSION=0.9.1
ARG TARGETARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    curl \
    ca-certificates \
    nmap \
    netcat-openbsd \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ligolo && cd /opt/ligolo \
    && curl -fsSL -o proxy.tar.gz \
       "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_proxy_${LIGOLO_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar -xzf proxy.tar.gz proxy \
    && rm proxy.tar.gz \
    && chmod +x proxy \
    && mv proxy /usr/local/bin/proxy

# Agent binaries for chaining a second/third hop live here too, so Kali can hand them
# out to pivots over the tunnel without needing a separate download step mid-lab.
RUN cd /opt/ligolo \
    && curl -fsSL -o agent.tar.gz \
       "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar -xzf agent.tar.gz agent \
    && rm agent.tar.gz \
    && chmod +x agent

WORKDIR /root
CMD ["/bin/bash"]
