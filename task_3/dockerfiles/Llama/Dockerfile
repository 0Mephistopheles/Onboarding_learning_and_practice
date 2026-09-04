FROM debian:stable-slim AS builder

RUN apt-get update && apt-get install -y build-essential cmake git wget libgomp1 curl && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ggml-org/llama.cpp.git /src

RUN cmake -S /src -B /src/build -DCMAKE_BUILD_TYPE=Release && cmake --build /src/build --config Release

RUN mkdir -p /runtime/lib && find /src/build -name "*.so*" -exec cp -P {} /runtime/lib/ \;

RUN mkdir -p /models && wget -O /models/tinyllama.gguf "https://huggingface.co/tensorblock/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0-Q3_K_M.gguf"

FROM debian:stable-slim

RUN apt-get update && apt-get install -y libgomp1 curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/bin/ /usr/local/bin/

COPY --from=builder /runtime/lib/ /usr/local/lib/

ENV LD_LIBRARY_PATH=/usr/local/lib

RUN mkdir -p /tinyllama_app/model

COPY --from=builder /models/tinyllama.gguf /tinyllama_app/model/tinyllama.gguf

WORKDIR /tinyllama_app

CMD ["llama-server", "-m", "/tinyllama_app/model/tinyllama.gguf", "--host", "0.0.0.0", "--port", "8080"]