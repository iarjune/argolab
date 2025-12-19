FROM debian:bookworm-slim

ARG KARGO_VERSION=1.8.4

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       bash \
       git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/akuity/kargo/releases/download/v${KARGO_VERSION}/kargo-linux-amd64" -o /usr/local/bin/kargo \
    && chmod +x /usr/local/bin/kargo

COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT ["/usr/local/bin/run.sh"]
