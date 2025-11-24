# Google Antigravity Setup

## What is Google Antigravity?

Google Antigravity is an agentic development platform that enables developers to work at a higher, task-oriented level. It uses Gemini 3's advanced reasoning, tool use, and agentic coding capabilities.

## Opening This Project

```bash
antigravity /path/to/resume-tweaker
```

Or from within Antigravity: File → Open Folder → Select `resume-tweaker`

## Project Context for Agents

### Project Overview

This is a **Resume Tweaker** application built with:
- **Backend**: Go + Chi router
- **Templates**: Templ (type-safe)
- **Interactivity**: Datastar (SSE streaming)
- **Database**: PostgreSQL + sqlc
- **LLM Integration**: BAML with Claude
- **Styling**: Tailwind CSS + shadcn/ui tokens
- **Deployment**: Railway via Railpack
- **Dev Environment**: Flox

### Key Files & Directories

```
resume-tweaker/
├── main.go                 # Entry point
├── handlers/
│   ├── routes.go           # Chi router + middleware
│   ├── pages.go            # Page handlers
│   └── api.go              # SSE streaming endpoint
├── templates/
│   ├── layout.templ        # Base layout
│   ├── landing.templ       # Landing page
│   └── tweak.templ         # Main interface
├── static/css/
│   ├── input.css           # Tailwind source
│   └── output.css          # Compiled CSS
├── db/
│   ├── migrations/         # SQL migrations
│   └── queries.sql         # sqlc queries
├── baml_src/
│   └── resume.baml         # BAML function definitions
├── docs/                   # Documentation (Obsidian vault)
├── go.mod
├── Makefile
└── railpack.toml           # Railway build config
```

### Important Documentation

- `docs/specification.md` - Product requirements
- `docs/deployment.md` - Railway deployment guide
- `docs/development.md` - Local development setup
- `TODO.md` - Current task list

### Environment Setup

```bash
# Local development with Flox
flox activate
flox services start  # Starts PostgreSQL

# Start development server
make dev
```

### Common Tasks

**Run the development server:**
```bash
make dev
```

**Generate templates:**
```bash
make generate
```

**Build CSS:**
```bash
make css-build
```

**Run migrations:**
```bash
make migrate
```

**Deploy to Railway:**
```bash
git push origin main
```

### Testing the App

1. Start server: `make dev`
2. Visit: http://localhost:8080
3. Health check: http://localhost:8080/health

### Architecture Notes

- **Streaming**: LLM responses stream via SSE + Datastar
- **Session Tracking**: Anonymous sessions via cookies (planned)
- **Database**: Two tables - `resumes` and `tweak_results`
- **Routes**: `/` (landing), `/tweak` (main), `/health`

## Tips for Working with Agents

1. **Be specific**: "Update the tweak handler to integrate BAML streaming"
2. **Reference files**: "Check the BAML definition in baml_src/resume.baml"
3. **Test iteratively**: Ask agents to test changes after implementation
4. **Check docs/**: Documentation is in Obsidian-compatible format

## Resources

- [Go Documentation](https://go.dev/doc/)
- [Chi Router](https://github.com/go-chi/chi)
- [Templ](https://templ.guide/)
- [Datastar](https://data-star.dev/)
- [BAML Documentation](https://docs.boundaryml.com/)
