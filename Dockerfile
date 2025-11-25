# Build stage
FROM golang:1.25-bookworm AS builder

WORKDIR /app

# Install build dependencies for CGO
RUN apt-get update && apt-get install -y gcc libc6-dev

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build with CGO enabled
ENV CGO_ENABLED=1
RUN go build -ldflags="-w -s" -o server .

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy binary, static files, and start script
COPY --from=builder /app/server .
COPY --from=builder /app/static ./static
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/start.sh .
RUN chmod +x start.sh

# Expose port
EXPOSE 8080

# Run via start script (handles superuser setup from env vars)
CMD ["./start.sh"]
