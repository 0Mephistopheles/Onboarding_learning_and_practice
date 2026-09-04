FROM debian:bookworm-slim as builder

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv libgomp1 curl && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /open_webui/venv

RUN /open_webui/venv/bin/pip install --no-cache-dir open-webui

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y python3 curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /open_webui /open_webui

ENV PATH=/open_webui/venv/bin:$PATH

WORKDIR /open_webui

EXPOSE 8080

CMD ["open-webui", "serve", "--host", "0.0.0.0", "--port", "8080"]