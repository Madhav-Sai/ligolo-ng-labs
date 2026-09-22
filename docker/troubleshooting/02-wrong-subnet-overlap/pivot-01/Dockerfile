FROM debian:bookworm-slim

ARG LIGOLO_VERSION=0.9.1
ARG TARGETARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iputils-ping curl ca-certificates netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ligolo && cd /opt/ligolo \
    && curl -fsSL -o agent.tar.gz \
       "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar -xzf agent.tar.gz agent && rm agent.tar.gz && chmod +x agent \
    && mv agent /usr/local/bin/agent

CMD ["/bin/bash"]
