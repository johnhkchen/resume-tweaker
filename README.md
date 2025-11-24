# Resume Tweaker

**The AI-powered resume optimization tool for job seekers.**

Resume Tweaker uses LLM technology (via BAML and Claude) to help you tailor your resume to specific job descriptions with real-time streaming feedback.

---

## Overview

- **Domain**: resume.tweaking.app
- **Stack**: Go + Chi + Templ + Datastar + Tailwind CSS
- **LLM**: BAML with Claude (Anthropic)
- **Database**: PostgreSQL + sqlc
- **Deployment**: Railway via Railpack
- **Dev Environment**: Flox

## Features

- **Paste & Tweak**: Input your resume and job description
- **Real-time Streaming**: Watch as AI suggestions appear via SSE
- **Session Tracking**: Anonymous history of your tweaks (planned)
- **Job-Specific**: Tailored to each job description
- **Privacy-First**: No account required, session-based tracking

## Quick Start

```bash
# Enter Flox environment (installs Go, Node.js, PostgreSQL)
flox activate

# Generate templates and build CSS
make generate
make css-build

# Start development server
make dev

# Open http://localhost:8080
```

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go 1.23+ |
| Router | Chi |
| Templates | Templ (type-safe) |
| Interactivity | Datastar (SSE-native) |
| Styling | Tailwind CSS + shadcn/ui tokens |
| LLM Framework | BAML |
| Database | PostgreSQL + sqlc |
| Deployment | Railway (Railpack) |
| Dev Environment | Flox |

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
├── go.mod
├── tailwind.config.js
├── Makefile
└── railpack.toml           # Railway build config
```

## Development Commands

```bash
make help       # Show all commands
make dev        # Start development server
make generate   # Generate templ + sqlc
make css        # Watch Tailwind CSS
make css-build  # Build minified CSS
make migrate    # Run database migrations
make build      # Build production binary
make clean      # Remove build artifacts
```

## Routes

| Path | Method | Purpose |
|------|--------|---------|
| `/` | GET | Landing page |
| `/tweak` | GET | Main tweak interface |
| `/api/tweak/stream` | POST | SSE streaming endpoint |
| `/health` | GET | Health check for Railway |

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `PORT` | Server port (default: 8080) |
| `DATABASE_URL` | PostgreSQL connection string |
| `ANTHROPIC_API_KEY` | For BAML/Claude |
| `SESSION_SECRET` | Cookie signing (optional) |

## Flox + Railpack Philosophy

This project uses **Flox** for local development and **Railpack** for deployment:

- **Flox** provides the complete dev environment (Go, Node.js, PostgreSQL)
- **Railpack** provides zero-config Railway deployment
- **Declarative configuration** over handwritten Dockerfiles
- The Arch Linux / Nix mindset: declare dependencies, let the platform handle it

## Railway Deployment

Railway project is configured with:
- PostgreSQL database addon
- Custom domain: resume.tweaking.app
- Auto-deployment on push to main
- Health check monitoring at `/health`

Push to main to deploy:

```bash
git push origin main
```

## Current Status

**MVP Complete**:
- Go project scaffolding with Chi router
- Templ templates with shadcn/ui styling
- Datastar integration for SSE streaming
- Health check endpoint
- Railpack configuration for Railway

**Next Steps**:
- Integrate BAML Go SDK for actual LLM calls
- Set up PostgreSQL database with sqlc
- Implement session tracking
- Add profile page with history

## Documentation

- [specification.md](specification.md) - Full project specification
- [TRANSITION.md](TRANSITION.md) - Why we moved from Elixir to Go
- [DEPLOYMENT.md](DEPLOYMENT.md) - Railway deployment guide
- [TODO.md](TODO.md) - Task tracking

---

Part of the [tweaking.app](https://tweaking.app) family
