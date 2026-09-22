# Same as the normal pivot-01 image, but with iptables installed and a startup script
# that (deliberately, for the exercise) drops inbound TCP/11601 - the port you'll be
# told to use for listener_add. The agent itself connects out fine; the SECOND agent
# trying to reach this pivot's listener will time out. That's the bug to find.
FROM debian:bookworm-slim

ARG LIGOLO_VERSION=0.9.1
ARG TARGETARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 iputils-ping curl ca-certificates netcat-openbsd iptables \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ligolo && cd /opt/ligolo \
    && curl -fsSL -o agent.tar.gz \
       "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar -xzf agent.tar.gz agent && rm agent.tar.gz && chmod +x agent \
    && mv agent /usr/local/bin/agent

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
