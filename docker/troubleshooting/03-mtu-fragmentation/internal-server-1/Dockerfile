# Same as the normal internal-server-1, but serves a deliberately large response body
# (a few hundred KB) so a low-MTU path downstream actually has something big enough to
# choke on.
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends iproute2 iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /srv/www
COPY index.html /srv/www/index.html
COPY generate_large_file.py /tmp/generate_large_file.py
RUN python3 /tmp/generate_large_file.py

WORKDIR /srv/www
EXPOSE 80
CMD ["python3", "-m", "http.server", "80"]
