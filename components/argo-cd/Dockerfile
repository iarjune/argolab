FROM admarketplace/amp-python:3.9

LABEL com.admarketplace.maintainer=ci@admarketplace.com \
      com.admarketplace.description=https://bitbucketcloudintegration@bitbucket.org/admarketplace/ci-docker-argocd-cli.git

WORKDIR /app

RUN apt-get update && \
    apt-get install -y curl jq && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r argocd && \
    useradd -r -g argocd -m -d /home/argocd -s /bin/bash argocd && \
    chown -R argocd:argocd /app

ENV ARGO_VERSION=v2.12.13
#    ARGO_HTTP1=true \
#    ARGO_SECURE=true \
#    ARGO_BASE_HREF='' \
#    KUBECONFIG=/dev/null 

RUN curl -sSL https://github.com/argoproj/argo-cd/releases/download/${ARGO_VERSION}/argocd-linux-amd64 \
    -o /usr/local/bin/argocd && \
    chmod +x /usr/local/bin/argocd

USER argocd

ENTRYPOINT ["argocd"]
