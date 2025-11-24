# Local Development Guide

#development

## Prerequisites

- [Flox](https://flox.dev) installed
- Git

## Quick Start

```bash
# Clone the repository
git clone https://github.com/johnhkchen/resume-tweaker.git
cd resume-tweaker

# Activate Flox environment (installs Go, Node.js, PostgreSQL)
flox activate

# Start PostgreSQL service
flox services start

# Generate templates and build CSS
make generate
make css-build

# Start development server
make dev

# Open http://localhost:8080
```

## Flox Environment

Flox provides a reproducible development environment with:
- Go 1.23+
- Node.js (for Tailwind CSS CLI)
- PostgreSQL

The environment is defined in `.flox/env/manifest.toml`.

### Services

```bash
# Start PostgreSQL
flox services start

# Check service status
flox services status

# Stop services
flox services stop
```

### Environment Variables

Set in `.env` for local development:

```bash
PORT=8080
DATABASE_URL=postgres://postgres:postgres@localhost/resume_tweaker_dev
ANTHROPIC_API_KEY=sk-ant-...
```

## Make Commands

```bash
make help       # Show all commands
make dev        # Start development server
make generate   # Generate templ + sqlc
make css        # Watch Tailwind CSS (for development)
make css-build  # Build minified CSS (for production)
make migrate    # Run database migrations
make build      # Build production binary
make clean      # Remove build artifacts
```

## Project Structure

```
resume-tweaker/
├── main.go                 # Entry point
├── handlers/
│   ├── routes.go           # Chi router setup
│   ├── pages.go            # Page handlers
│   └── api.go              # SSE streaming endpoint
├── templates/
│   ├── layout.templ        # Base layout
│   ├── landing.templ       # Landing page
│   └── tweak.templ         # Main tweak interface
├── static/css/
│   ├── input.css           # Tailwind source
│   └── output.css          # Compiled CSS
├── db/
│   ├── migrations/         # SQL migrations
│   └── queries.sql         # sqlc queries
├── baml_src/
│   └── resume.baml         # BAML definitions
├── docs/                   # Documentation (Obsidian vault)
├── go.mod
├── tailwind.config.js
├── Makefile
└── railpack.toml           # Railway build config
```

## Development Workflow

### 1. Making Template Changes

Edit `.templ` files, then regenerate:

```bash
make generate
```

Or use watch mode:

```bash
templ generate --watch
```

### 2. Making CSS Changes

Edit `static/css/input.css` or `tailwind.config.js`, then:

```bash
make css  # Watch mode
# or
make css-build  # One-time build
```

### 3. Database Changes

Create a new migration:

```bash
# Create migration file manually in db/migrations/
# Then run:
make migrate
```

Update sqlc queries in `db/queries.sql`, then:

```bash
make generate
```

### 4. Testing the App

1. Start server: `make dev`
2. Visit: http://localhost:8080
3. Health check: http://localhost:8080/health

## Code Generation

This project uses code generation for:
- **Templ**: Type-safe HTML templates → `*_templ.go` files
- **sqlc**: Type-safe SQL queries → `db/*.go` files (not yet implemented)

Generated files are committed to the repo for reliable Railway builds.

## Tailwind CSS

We use the Tailwind standalone CLI (not npm package) for simpler builds:

```bash
# Download CLI (done automatically by make css-build)
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/...

# Build CSS
./tailwindcss -i ./static/css/input.css -o ./static/css/output.css
```

## Related Documents

- [[specification]] - Project requirements
- [[deployment]] - Railway deployment
- [[reference/design]] - UI design reference
