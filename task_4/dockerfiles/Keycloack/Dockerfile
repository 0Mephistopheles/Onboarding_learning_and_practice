FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates openjdk-17-jre-headless && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /tmp/keycloak.tar.gz "https://github.com/keycloak/keycloak/releases/download/24.0.5/keycloak-24.0.5.tar.gz" && tar -xzf /tmp/keycloak.tar.gz -C /opt && mv /opt/keycloak-24.0.5 /opt/keycloak && rm /tmp/keycloak.tar.gz

COPY autho_realm.json /opt/keycloak/data/import/autho_realm.json

WORKDIR /opt/keycloak

EXPOSE 8080 9000

USER 1000

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]