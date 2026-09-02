FROM debian:stable-slim as builder

RUN apt-get update && apt-get install -y build-essential cmake git wget && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/ggml-org/llama.cpp.git /src

RUN cmake -S /src -B /src/build -DCMAKE_BUILD_TYPE=Release && cmake --build /src/build --config Release

RUN mkdir -p /RUNtime/lib && find /src/build -name "*.so*" -exec cp -P {} /RUNtime/lib/ \;

RUN mkdir -p /models && wget -O /models/tinyllama.gguf "https://huggingface.co/tensorblock/TinyLlama-1.>

FROM debian:stable-slim

RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/bin/ /usr/local/bin/

COPY --from=builder /RUNtime/lib/ /usr/local/lib/

ENV LD_LIBRARY_PATH=/usr/local/lib

COPY --from=builder /models/tinyllama.gguf /tinyllama_app/model/tinyllama.gguf

WORKDIR /tinyllama_app

CMD ["bash"]