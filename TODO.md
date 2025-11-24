# Resume Tweaker - TODO

## Current Status: Go MVP Complete

**Date**: November 24, 2025

The Go implementation is scaffolded and working locally.

## Completed

- [x] Go project scaffolding with Chi router
- [x] Templ templates (layout, landing, tweak)
- [x] Tailwind CSS with shadcn/ui design tokens
- [x] Datastar integration for SSE streaming
- [x] Health check endpoint
- [x] Flox environment configured
- [x] Railpack configuration for Railway
- [x] Documentation reorganized (Obsidian-ready)

## In Progress

### BAML Integration
- [ ] Install BAML Go SDK
- [ ] Generate BAML client from `baml_src/resume.baml`
- [ ] Wire up streaming to actual LLM
- [ ] Test with Anthropic API key

## Next Up

### Database
- [ ] Run migrations on Railway PostgreSQL
- [ ] Generate sqlc code
- [ ] Implement db package
- [ ] Save submissions and results

### Session Management
- [ ] Implement session cookie middleware
- [ ] Track anonymous user history

### Polish
- [ ] Error handling improvements
- [ ] Loading animations
- [ ] Mobile testing

## Future

- [ ] Profile page with history
- [ ] Export options (PDF, DOCX)
- [ ] Multiple LLM model selection
- [ ] Tests and CI/CD

## Quick Reference

### Commands

```bash
flox activate       # Enter dev environment
make dev            # Start server
make generate       # Generate templ
make css-build      # Build CSS
make build          # Production binary
```

### Routes

| Path | Purpose |
|------|---------|
| `/` | Landing page |
| `/tweak` | Main interface |
| `/api/tweak/stream` | SSE endpoint |
| `/health` | Health check |

### Environment

```
PORT=8080
DATABASE_URL=postgres://...
ANTHROPIC_API_KEY=sk-ant-...
```

## Documentation

All documentation is in `docs/` (Obsidian-compatible):
- `docs/specification.md` - Product spec
- `docs/deployment.md` - Railway guide
- `docs/development.md` - Local dev setup
- `docs/reference/design.md` - UI reference
