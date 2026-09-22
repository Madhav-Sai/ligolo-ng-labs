# internal-server-1: a host that only ever exists on the 172.16.10.0/24 network.
# It has no route to attack_net and no idea Kali exists. This is the target the whole
# lab is built to reach. It serves a tiny HTTP app with a flag string, which is enough
# to prove "I can browse to an internal-only service through the tunnel."
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /srv/www
COPY index.html /srv/www/index.html

WORKDIR /srv/www
EXPOSE 80
CMD ["python3", "-m", "http.server", "80"]
