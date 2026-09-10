FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl tar && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/oauth2-proxy.tar.gz "https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.15.2/oauth2-proxy-v7.15.2.linux-amd64.tar.gz" && tar -xzf /tmp/oauth2-proxy.tar.gz -C /tmp && mv "/tmp/oauth2-proxy-v7.15.2.linux-amd64/oauth2-proxy" /usr/local/bin/oauth2-proxy && chmod +x /usr/local/bin/oauth2-proxy && rm -rf /tmp/*

EXPOSE 4180

ENTRYPOINT ["oauth2-proxy"]