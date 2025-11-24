# Resume Tweaker - TODO

## Current Status: Auth Protected

**Date**: November 24, 2025
**URL**: https://resume.tweaking.app

Go MVP deployed with password auth. Frontend redesigned with Anchor's Sage & Slate design system.

## Priority: BAML Integration

Now that auth is in place, we can safely enable LLM calls:

- [ ] Install BAML Go SDK
- [ ] Create resume tweaking prompt (reference: `docs/reference/anchor/baml_src/resume.baml`)
- [ ] Wire up streaming endpoint with real LLM
- [ ] Add `ANTHROPIC_API_KEY` to Railway env vars
- [ ] Test end-to-end flow

## Future Work

### Database
- [ ] Run migrations on Railway PostgreSQL
- [ ] Generate sqlc code
- [ ] Save submissions and results

### Session Management
- [ ] Session cookies for tracking
- [ ] Anonymous user history

### OAuth (Phase 2 Auth)
- [ ] Add Google OAuth for real user accounts
- [ ] User-specific rate limiting
- [ ] Per-user history

## Completed

- [x] Go project with Chi router
- [x] Templ templates (layout, landing, tweak, login)
- [x] Anchor Sage & Slate design system
- [x] Datastar SSE streaming (placeholder with progress steps)
- [x] Health check endpoint
- [x] Railway deployment via Railpack
- [x] Custom domain SSL
- [x] Documentation (Obsidian-ready in `docs/`)
- [x] Password authentication (`AUTH_PASSWORD` env var)
- [x] Protected routes (`/tweak`, `/api/tweak/stream`)

## Quick Reference

```bash
flox activate       # Dev environment
make dev            # Start server
make generate       # Generate templ
make css-build      # Build CSS
```

| Route | Method | Auth | Purpose |
|-------|--------|------|---------|
| `/` | GET | Public | Landing |
| `/login` | GET/POST | Public | Login form |
| `/logout` | GET | Public | Clear session |
| `/tweak` | GET | Protected | Main UI |
| `/api/tweak/stream` | POST | Protected | SSE streaming |
| `/health` | GET | Public | Health check |

## Reference Code

Anchor project reference files for BAML prompts and UX patterns:

- `docs/reference/anchor/baml_src/` - BAML prompt definitions
- `docs/reference/anchor/components/` - Svelte streaming UI components

## Documentation

- `docs/specification.md` - Product spec
- `docs/deployment.md` - Railway guide
- `docs/development.md` - Local setup
