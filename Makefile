.PHONY: dev build generate clean css css-build migrate help

# Default target
help:
	@echo "Resume Tweaker - Development Commands"
	@echo ""
	@echo "  make dev        - Start development server (generates code first)"
	@echo "  make build      - Build production binary"
	@echo "  make generate   - Generate all code (templ, sqlc)"
	@echo "  make css        - Watch and compile Tailwind CSS"
	@echo "  make css-build  - Build minified Tailwind CSS"
	@echo "  make migrate    - Run database migrations"
	@echo "  make clean      - Remove build artifacts"

# Development
dev: generate css-build
	@echo "Starting dev server..."
	go run main.go

# Generate all code
generate: generate-templ generate-sqlc

generate-templ:
	@echo "Generating templ..."
	templ generate

generate-sqlc:
	@echo "Generating sqlc..."
	sqlc generate

# Build for production
build: generate css-build
	@echo "Building production binary..."
	CGO_ENABLED=0 go build -o bin/server main.go

# Tailwind CSS (watch mode) - uses standalone CLI
css: tailwindcss
	./tailwindcss -i ./static/css/input.css -o ./static/css/output.css --watch

# Tailwind CSS (production)
css-build: tailwindcss
	./tailwindcss -i ./static/css/input.css -o ./static/css/output.css --minify

# Download Tailwind standalone CLI if not present
tailwindcss:
	@if [ ! -f ./tailwindcss ]; then \
		echo "Downloading Tailwind CSS standalone CLI..."; \
		curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.16/tailwindcss-macos-arm64; \
		chmod +x tailwindcss-macos-arm64; \
		mv tailwindcss-macos-arm64 tailwindcss; \
	fi

# Database
migrate:
	psql $(DATABASE_URL) -f db/migrations/001_initial.sql

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f templates/*_templ.go
	rm -f db/db.go db/models.go db/queries.sql.go
