FROM python:3.12.5-slim-bookworm AS base

# Install GCC and build tools
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux \
    && apt-get update \
    && apt-get install -y gcc build-essential curl git \
    && apt-get clean; \
    rm -rf /var/lib/apt/lists/*

FROM base AS builder

# Use args
ARG USE_CUDA
ARG USE_CUDA_VER

## Basis ##
ENV ENV=prod \
    PORT=9099 \
    # pass build args to the build
    USE_CUDA_DOCKER=${USE_CUDA} \
    USE_CUDA_DOCKER_VER=${USE_CUDA_VER}

WORKDIR /app

# Install Python dependencies
COPY ./requirements.txt .
RUN pip3 install uv && \
    if [ "$USE_CUDA" = "true" ]; then \
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$USE_CUDA_DOCKER_VER --no-cache-dir; \
    else \
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --no-cache-dir; \
    fi
RUN uv pip install --system -r requirements.txt --no-cache-dir

# Copy the application code
COPY . .

# Expose the port
ENV HOST="0.0.0.0"
ENV PORT="9099"

ENTRYPOINT [ "bash", "start.sh" ]

FROM builder

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

# metadata
LABEL org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.vcs-url=${VCS_URL}
