FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    g++ \
    make \
    curl \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /app

# Copy source files
COPY main.cpp .
COPY httplib.h .
COPY index.html .

# Compile the C++ application
RUN g++ -std=c++17 -O2 -pthread main.cpp -o db

# Expose port
EXPOSE 8080

# Create startup script that runs Ollama and the database
RUN echo '#!/bin/bash\n\
    set -e\n\
    echo "Starting Ollama service..."\n\
    ollama serve &\n\
    OLLAMA_PID=$!\n\
    sleep 8\n\
    echo "Pulling embedding model (nomic-embed-text)..."\n\
    ollama pull nomic-embed-text || echo "Warning: Could not pull nomic-embed-text"\n\
    echo "Pulling LLM model (llama3.2:1b - smaller for free tier)..."\n\
    ollama pull llama3.2:1b || echo "Warning: Could not pull llama3.2:1b"\n\
    echo "Models ready. Starting VectorDB server..."\n\
    ./db' > /app/start.sh && chmod +x /app/start.sh

# Run the application
CMD ["/app/start.sh"]
