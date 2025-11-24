# Resume Tweaker - TODO

## Current Status: Transition to Go

**Date**: November 24, 2025

The project is transitioning from Elixir/Phoenix to Go. See [TRANSITION.md](TRANSITION.md) for full rationale.

## Completed (Elixir Era)

- [x] Phoenix project scaffolding
- [x] Database design (resumes, tweak_results tables)
- [x] BAML integration research
- [x] Flox environment setup
- [x] Railway deployment configuration
- [x] Railpack + Flox philosophy documentation
- [x] Resolved GLIBC issues with source compilation approach
- [x] **Decision to migrate to Go**

## Current Session: Cleanup

- [x] Remove Elixir-specific files
- [x] Create TRANSITION.md documentation
- [x] Update README for Go transition
- [ ] Update TODO.md (this file)
- [ ] Clean up remaining Elixir references
- [ ] Commit transition state

## Next Session: Go Foundation

### Phase 1: Hello World
- [ ] Initialize Go module: `go mod init github.com/johnhkchen/resume-tweaker`
- [ ] Update Flox manifest for Go
- [ ] Update `.tool-versions` for Go version
- [ ] Create basic HTTP server
- [ ] Add health check endpoint `/health`
- [ ] Test local server
- [ ] Deploy to Railway (test Railpack Go detection)

### Phase 2: BAML Integration
- [ ] Install BAML Go SDK
- [ ] Create `baml_src/` directory
- [ ] Define TweakResume function in BAML
- [ ] Create Go wrapper for BAML client
- [ ] Test streaming with simple example
- [ ] Verify OpenAI API integration

### Phase 3: Database Layer
- [ ] Choose database library (GORM vs sqlc vs raw SQL)
- [ ] Create database models (Resume, TweakResult)
- [ ] Write migrations
- [ ] Test database operations locally
- [ ] Run migrations on Railway

### Phase 4: Core Feature
- [ ] Create HTTP handler for resume tweaking
- [ ] Implement streaming response (SSE)
- [ ] Save submissions to database
- [ ] Save results to database
- [ ] Add anonymous session tracking (cookies)
- [ ] Test end-to-end flow

### Phase 5: Frontend (Stub)
- [ ] Choose templating (html/template, templ, or HTMX)
- [ ] Create simple form (resume + job description textareas)
- [ ] Display streaming output
- [ ] Add basic error handling
- [ ] Style with minimal CSS

### Phase 6: Deployment
- [ ] Test full deployment on Railway
- [ ] Verify health checks working
- [ ] Test with actual OpenAI API key
- [ ] Verify database persistence
- [ ] Update DEPLOYMENT.md for Go specifics

## Technology Decisions Needed

### Web Framework
- [ ] stdlib `net/http` - Simplest, most standard
- [ ] `chi` - Lightweight router
- [ ] `echo` - More features, still simple

**Recommendation**: Start with `chi` for routing, otherwise stdlib

### Database
- [ ] GORM - Full ORM, familiar for devs
- [ ] sqlc - Type-safe SQL generation
- [ ] database/sql - Raw SQL, most control

**Recommendation**: GORM for speed, can refactor later

### Templates
- [ ] `html/template` - Stdlib, simple
- [ ] `templ` - Type-safe, modern
- [ ] API + HTMX - Minimal JS

**Recommendation**: `templ` for type safety, matches Go philosophy

### Streaming
- [ ] Server-Sent Events (SSE) - Simpler, unidirectional
- [ ] WebSockets - More complex, bidirectional

**Recommendation**: SSE - perfect for LLM streaming

## Architecture Notes

### Project Structure
```
resume-tweaker/
├── cmd/
│   └── server/
│       └── main.go              # Entry point
├── internal/
│   ├── api/
│   │   ├── handler.go           # HTTP handlers
│   │   ├── middleware.go        # Session, logging
│   │   └── routes.go            # Route definitions
│   ├── llm/
│   │   ├── baml.go              # BAML wrapper
│   │   └── types.go             # LLM types
│   ├── models/
│   │   ├── resume.go            # Database models
│   │   └── db.go                # Database connection
│   └── session/
│       └── session.go           # Session management
├── baml_src/
│   └── main.baml                # BAML function definitions
├── static/                       # CSS, JS, images
├── templates/                    # HTML templates
├── migrations/                   # SQL migrations
├── go.mod                        # Go dependencies
├── go.sum                        # Checksums
└── Makefile                      # Build commands
```

### Key Differences from Elixir Version
- No complex framework (Phoenix → chi)
- Simpler build (static binary vs release)
- No NIF complexity (pure Go)
- Standard library streaming (SSE)
- Familiar patterns for more developers

## Flox Environment (Planned)

```toml
# .flox/env/manifest.toml
[install]
go.pkg-path = "go"
postgresql.pkg-path = "postgresql"

[vars]
PGDATA = "$FLOX_ENV_CACHE/postgres"
PGHOST = "$FLOX_ENV_CACHE/postgres"

[services]
postgres.command = "postgres -k $PGHOST"
```

## Railpack Configuration (Planned)

```toml
# railpack.toml
# May not even be needed! Railpack auto-detects Go via go.mod
# Much simpler than Elixir version (no Rust, no native deps)
```

## Lessons from Elixir Experience

### What to Keep
- Railpack + Flox philosophy
- Declarative configuration approach
- Railway deployment setup
- Documentation structure
- Design inspiration (Anchor project)

### What to Avoid
- Complex frameworks when simple works
- Native dependencies with version mismatches
- Precompiled binaries for deployment
- Community packages vs first-class support

### What We Learned
- Platform thinking matters (Arch/Nix mindset)
- Source compilation solves GLIBC issues
- Sometimes simpler stack is better
- BAML + Go is more natural fit

## References

### Go Development
- [Go Documentation](https://go.dev/doc/)
- [Chi Router](https://github.com/go-chi/chi)
- [GORM](https://gorm.io/)
- [Templ](https://templ.guide/)

### BAML
- [BAML Documentation](https://docs.boundaryml.com/)
- [BAML Go Examples](https://github.com/BoundaryML/baml/tree/main/examples/go)

### Deployment
- [Railpack Go Support](https://railpack.com/languages/go/)
- [Railway Go Guide](https://docs.railway.com/guides/go)

## Notes

- Railway deployment is already configured
- PostgreSQL database addon is ready
- Custom domain (resume.tweaking.app) is set up
- This transition keeps the good parts, fixes the pain points

---

**Next session starts here**: Initialize Go module and create basic HTTP server
