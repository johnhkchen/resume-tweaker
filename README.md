# Resume Tweaker

**The AI-powered resume optimization tool for job seekers.**

Resume Tweaker uses LLM technology (via BAML and GPT-4o-mini) to help you tailor your resume to specific job descriptions with real-time streaming feedback.

---

## ⚠️ In Transition: Elixir → Go

This project is transitioning from Elixir/Phoenix to Go. See [TRANSITION.md](TRANSITION.md) for details.

**Current Status**: Elixir files removed, ready for Go implementation in next session.

**Why Go?**
- BAML has first-class Go support (vs community-maintained Elixir package)
- Static binaries avoid GLIBC version mismatches
- Simpler deployment with Railpack
- Better ecosystem fit

**What's Staying:**
- ✅ Flox + Railpack philosophy
- ✅ Railway deployment
- ✅ Design documentation and references
- ✅ Zero-config approach

---

## Overview

- **Domain**: resume.tweaking.app
- **Stack**: Go + BAML + PostgreSQL (planned)
- **LLM**: BAML with OpenAI GPT-4o-mini
- **Deployment**: Railway via Railpack
- **Dev Environment**: Flox

## Features (Planned)

- 📝 **Paste & Tweak**: Input your resume and job description
- ⚡ **Real-time Streaming**: Watch as AI suggestions appear
- 💾 **Session Tracking**: Anonymous history of your tweaks
- 🎯 **Job-Specific**: Tailored to each job description
- 🔒 **Privacy-First**: No account required, session-based tracking

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go (planned) |
| LLM Framework | BAML (first-class Go support) |
| Database | PostgreSQL |
| Deployment | Railway (Railpack) |
| Dev Environment | Flox |

## Flox + Railpack Philosophy

This project uses **Flox** for local development and **Railpack** for deployment:

- **Flox** provides the complete dev environment
- **Railpack** provides zero-config Railway deployment
- **Declarative configuration** over handwritten Dockerfiles
- The Arch Linux / Nix mindset: declare dependencies, let the platform handle it

### Why This Approach
- **No custom Dockerfiles** - Railpack handles everything
- **Reproducible environments** - Flox ensures consistency
- **Platform-native** - Uses tools as designed
- **Simple maintenance** - Declarative config in version control

## Documentation

- [TRANSITION.md](TRANSITION.md) - Why we moved from Elixir to Go
- [DEPLOYMENT.md](DEPLOYMENT.md) - Railway deployment guide (will be updated for Go)
- [TODO.md](TODO.md) - Task tracking
- [specification.md](specification.md) - Original project specification
- [FRONTEND_REFERENCE.md](FRONTEND_REFERENCE.md) - UI design inspiration
- [.claude/antigravity.md](.claude/antigravity.md) - Google Antigravity setup

## Design Philosophy

Inspired by the **Anchor** project (see `sample_code/`):
- Calm, focused interface
- Minimal cognitive load
- Clear action steps
- Real-time feedback

## Railway Deployment

Railway project is already configured:
- PostgreSQL database addon connected
- Custom domain: resume.tweaking.app
- Auto-deployment on push to main
- Health check monitoring

See [DEPLOYMENT.md](DEPLOYMENT.md) for full details.

## Next Steps

For the next session (Go implementation):

1. **Initialize Go module**
2. **Setup Flox environment** with Go + PostgreSQL
3. **Create basic HTTP server** with health check
4. **Integrate BAML Go SDK**
5. **Implement resume tweaking** with streaming
6. **Deploy to Railway**

See [TRANSITION.md](TRANSITION.md) for detailed implementation plan.

## Contributing

This is an MVP in transition. The Elixir implementation has been removed in favor of Go.

Future improvements:
- Complete Go implementation
- Enhanced UI based on Anchor design patterns
- Profile page with submission history
- Multiple LLM model support
- Export formats (PDF, DOCX)

## Support

For questions about the transition:
- Check [TRANSITION.md](TRANSITION.md) for rationale
- Review [TODO.md](TODO.md) for current status
- See [specification.md](specification.md) for product requirements

---

Built with ❤️ using the Railway/Arch philosophy
