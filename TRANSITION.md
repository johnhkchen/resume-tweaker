# Transition: Elixir → Go

**Date**: November 24, 2025
**Status**: Ready for Go implementation

## Decision

After encountering GLIBC compatibility issues with `baml_elixir` (Rust NIF dependencies), we've decided to transition from Elixir/Phoenix to Go.

## Rationale

### Why Move Away from Elixir
1. **Native dependency complexity** - Rust NIFs require careful GLIBC version management
2. **BAML ecosystem** - Go has first-class BAML support (not community-maintained)
3. **Deployment friction** - Even with Railpack's source compilation, adds build complexity
4. **Team familiarity** - Go may be more accessible for future contributors

### Why Go is Better for This Project
1. **BAML first-class support** - Official Go SDK, better maintained
2. **Static binaries** - No GLIBC version mismatches, simpler deployment
3. **Simpler stack** - Standard HTTP server, no complex framework
4. **Railpack support** - Railway/Railpack handles Go natively
5. **Streaming** - Native SSE/streaming support for LLM responses

## What We're Keeping

### Philosophy & Approach ✅
- **Flox** for local development environment
- **Railpack** for zero-config Railway deployment
- **Declarative configuration** over handwritten Dockerfiles
- The Arch Linux / Nix mindset

### Documentation ✅
- `DEPLOYMENT.md` - Railway/Railpack philosophy (will be updated for Go)
- `FRONTEND_REFERENCE.md` - UI design inspiration from Anchor project
- `specification.md` - Core product requirements
- `.claude/antigravity.md` - Google Antigravity setup guide
- `sample_code/` - Frontend reference

### Infrastructure ✅
- Railway project connection
- PostgreSQL database addon
- Custom domain setup (resume.tweaking.app)
- Health check endpoint pattern
- Session-based tracking approach

## What We're Removing

### Elixir-Specific Files ❌
- `lib/` - Phoenix application code
- `priv/` - BAML files, migrations, static assets
- `config/` - Phoenix configuration
- `assets/` - Frontend assets
- `test/` - ExUnit tests
- `mix.exs`, `mix.lock` - Elixir dependencies
- `.formatter.exs` - Elixir code formatter

### Adjusting for Go
- `.tool-versions` - Will update for Go version
- `railpack.toml` - Will update for Go (no Rust needed!)
- `railway.json` - Will update start command

## Lessons Learned

### What Worked Well
1. **Railpack philosophy** - Declarative config beats Dockerfiles
2. **The 5 Whys analysis** - Led us to the right solution (even if temporary)
3. **Understanding the platform** - Thinking like Arch/Nix users helped
4. **Flox integration** - Excellent local dev experience

### What Didn't Work
1. **Precompiled NIFs** - GLIBC version mismatches are painful
2. **Community packages** - `baml_elixir` lacks official support
3. **Native dependencies** - Even with source compilation, adds friction

## Next Session: Go Implementation

### Project Structure (Proposed)
```
resume-tweaker/
├── cmd/
│   └── server/
│       └── main.go          # Entry point
├── internal/
│   ├── api/                 # HTTP handlers
│   ├── llm/                 # BAML client wrapper
│   ├── models/              # Database models (GORM?)
│   └── session/             # Session management
├── baml_src/                # BAML function definitions
├── static/                  # Frontend assets
├── templates/               # HTML templates (templ?)
├── go.mod                   # Go dependencies
├── go.sum                   # Dependency checksums
├── Makefile                 # Build commands
└── .flox/                   # Flox environment
```

### Stack Decisions Needed
- **Web framework**: stdlib `net/http`, `chi`, or `echo`?
- **Database**: GORM, sqlc, or raw SQL?
- **Templates**: `html/template`, `templ`, or API + HTMX?
- **BAML integration**: Direct SDK or wrapper?
- **Streaming**: SSE (Server-Sent Events) or WebSockets?

### Implementation Order
1. **Hello World** - Basic HTTP server + health check
2. **BAML Integration** - Test streaming with simple example
3. **Database Layer** - Models and migrations
4. **Resume Tweaking** - Core feature with streaming
5. **Session Management** - Anonymous tracking
6. **Frontend** - Keep it simple (stub like Elixir version)

### Flox Environment Updates
```toml
# .flox/env/manifest.toml (proposed)
[install]
go.pkg-path = "go"
postgresql.pkg-path = "postgresql"

[vars]
PGDATA = "$FLOX_ENV_CACHE/postgres"
PGHOST = "$FLOX_ENV_CACHE/postgres"

[services]
postgres.command = "postgres -k $PGHOST"
```

### Railpack Configuration Updates
```toml
# railpack.toml (will be simpler!)
# Go compiles to static binary - no native dependency complexity!
# May not even need this file if Railpack auto-detects via go.mod
```

## Migration Checklist

### Before Starting Go Implementation
- [x] Remove Elixir files
- [ ] Update `.tool-versions` for Go
- [ ] Update `railpack.toml` for Go
- [ ] Update Flox manifest for Go
- [ ] Update `README.md` with Go stack
- [ ] Update `DEPLOYMENT.md` for Go specifics

### First Go Session
- [ ] Initialize Go module: `go mod init github.com/johnhkchen/resume-tweaker`
- [ ] Create basic HTTP server with health check
- [ ] Test Railpack deployment with static binary
- [ ] Integrate BAML Go SDK
- [ ] Test streaming endpoint

## References

### Go + BAML
- [BAML Go Documentation](https://docs.boundaryml.com/)
- [BAML GitHub](https://github.com/BoundaryML/baml)

### Go Web Development
- [Go net/http](https://pkg.go.dev/net/http)
- [Chi Router](https://github.com/go-chi/chi)
- [Templ](https://templ.guide/)

### Railway + Go
- [Railpack Go Support](https://railpack.com/languages/go/)
- [Railway Go Deployment](https://docs.railway.com/guides/go)

## Why This is Still Better Than Custom Dockerfiles

Even with the language change:
- Static Go binary = simpler than Elixir release
- No native dependencies = no GLIBC issues
- Railpack auto-detects Go = zero config
- Flox manages Go version locally
- Same Railway/Arch philosophy applies

**The approach was right. The language choice just needed adjustment.**

---

*Transition documented at 2025-11-24*
