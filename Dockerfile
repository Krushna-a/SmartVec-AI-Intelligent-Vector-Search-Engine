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
    ollama serve &\n\
    sleep 5\n\
    ollama pull nomic-embed-text &\n\
    ollama pull llama3.2 &\n\
    sleep 10\n\
    ./db' > /app/start.sh && chmod +x /app/start.sh

# Run the application
CMD ["/app/start.sh"]
