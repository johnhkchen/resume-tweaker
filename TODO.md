# Resume Tweaker - TODO

## Current Status: First Deploy Live

**Date**: November 24, 2025
**URL**: https://resume.tweaking.app

Go MVP deployed to Railway. UI works, streaming placeholder functional.

## Priority: Authentication

**Before enabling LLM calls**, we need auth to prevent abuse:

- [ ] Choose auth strategy (OAuth? Magic link? Simple password?)
- [ ] Implement auth middleware
- [ ] Protect `/api/tweak/stream` endpoint
- [ ] Add login/logout UI

Options to consider:
1. **OAuth (Google/GitHub)** - Best UX, more setup
2. **Magic link email** - Simple, needs email service
3. **Simple shared password** - Quick MVP protection
4. **Rate limiting by IP** - Supplement, not replacement

## After Auth

### BAML Integration
- [ ] Install BAML Go SDK
- [ ] Generate client from `baml_src/resume.baml`
- [ ] Wire up streaming endpoint
- [ ] Test with Anthropic API key

### Database
- [ ] Run migrations on Railway PostgreSQL
- [ ] Generate sqlc code
- [ ] Save submissions and results

### Session Management
- [ ] Session cookies for tracking
- [ ] Anonymous user history

## Completed

- [x] Go project with Chi router
- [x] Templ templates (layout, landing, tweak)
- [x] Tailwind CSS + shadcn/ui tokens
- [x] Datastar SSE streaming (placeholder)
- [x] Health check endpoint
- [x] Railway deployment via Railpack
- [x] Custom domain SSL
- [x] Documentation (Obsidian-ready in `docs/`)

## Quick Reference

```bash
flox activate       # Dev environment
make dev            # Start server
make generate       # Generate templ
make css-build      # Build CSS
```

| Route | Purpose |
|-------|---------|
| `/` | Landing |
| `/tweak` | Main UI |
| `/api/tweak/stream` | SSE (needs auth!) |
| `/health` | Health check |

## Documentation

- `docs/specification.md` - Product spec
- `docs/deployment.md` - Railway guide
- `docs/development.md` - Local setup
