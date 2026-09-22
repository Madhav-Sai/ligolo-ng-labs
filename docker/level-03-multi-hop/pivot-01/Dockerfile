# Pivot-01: the dual-homed compromised host. Faces Kali on 10.10.10.0/24 and the
# internal network on 172.16.10.0/24. The agent binary runs here WITHOUT root — that's
# realistic (it's usually the shell you already popped) and it's also a deliberate
# design point of Ligolo-ng: no privilege needed on the agent side at all.
FROM debian:bookworm-slim

ARG LIGOLO_VERSION=0.9.1
ARG TARGETARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    curl \
    ca-certificates \
    netcat-openbsd \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/ligolo && cd /opt/ligolo \
    && curl -fsSL -o agent.tar.gz \
       "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VERSION}/ligolo-ng_agent_${LIGOLO_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar -xzf agent.tar.gz agent \
    && rm agent.tar.gz \
    && chmod +x agent \
    && mv agent /usr/local/bin/agent

# Create an unprivileged user to actually run the agent as, so the lab proves the
# "agent needs no admin/root" claim instead of just asserting it.
RUN useradd -m -s /bin/bash www-shell
USER root
WORKDIR /home/www-shell
CMD ["/bin/bash"]
