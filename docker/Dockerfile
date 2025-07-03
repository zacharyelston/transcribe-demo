FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Whisper and other dependencies
RUN pip install --no-cache-dir \
    openai-whisper \
    torch \
    torchaudio \
    pydantic \
    pyyaml \
    pytest \
    pytest-cov

# Default command
CMD ["python", "run.py"]
