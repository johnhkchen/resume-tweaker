# Resume Tweaker

**The AI-powered resume optimization tool for job seekers.**

Resume Tweaker uses LLM technology (via BAML and GPT-4o-mini) to help you tailor your resume to specific job descriptions with real-time streaming feedback.

## Overview

- **Domain**: resume.tweaking.app
- **Stack**: Elixir + Phoenix + LiveView + PostgreSQL
- **LLM**: BAML with OpenAI GPT-4o-mini
- **Deployment**: Railway via Railpack
- **Dev Environment**: Flox

## Features

- 📝 **Paste & Tweak**: Input your resume and job description
- ⚡ **Real-time Streaming**: Watch as AI suggestions appear
- 💾 **Session Tracking**: Anonymous history of your tweaks
- 🎯 **Job-Specific**: Tailored to each job description
- 🔒 **Privacy-First**: No account required, session-based tracking

## Quick Start

### Prerequisites

- [Flox](https://flox.dev/) installed
- OpenAI API key

### Local Development

```bash
# Clone the repository
git clone <repository-url>
cd resume-tweaker

# Activate Flox environment
flox activate

# Start PostgreSQL service
flox services start

# Set up database
mix ecto.create
mix ecto.migrate

# Copy environment template and add your API key
cp .env.example .env
# Edit .env and add: OPENAI_API_KEY=your_key_here

# Start the Phoenix server
mix phx.server
```

Visit http://localhost:4000

### Using Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Link to your Railway project
railway link

# Run commands in Railway environment
railway run mix ecto.migrate
```

## Project Structure

```
resume-tweaker/
├── lib/
│   ├── resume_tweaker/         # Core business logic
│   │   ├── llm.ex             # BAML LLM client wrapper
│   │   ├── resumes.ex         # Database context
│   │   └── resumes/           # Schemas (Resume, TweakResult)
│   └── resume_tweaker_web/    # Web layer
│       ├── live/              # LiveView UI
│       │   └── tweak_live.ex  # Main interface
│       └── router.ex          # Routes
├── priv/
│   ├── baml_src/              # BAML function definitions
│   │   └── main.baml         # TweakResume function
│   └── repo/migrations/       # Database migrations
├── config/                     # Application configuration
├── sample_code/               # UI design reference (Anchor)
└── .flox/                     # Flox environment
```

## Routes

- `/` - Main resume tweaking interface
- `/profile` - User submission history (planned)
- `/health` - Health check endpoint

## Database Schema

### resumes
- `original_content` - Input resume
- `job_description` - Target job posting
- `session_id` - Anonymous session tracking
- `metadata` - Extensible JSON field

### tweak_results
- `resume_id` - Foreign key to resumes
- `tweaked_content` - LLM-generated output
- `model_used` - LLM model identifier
- `prompt_tokens`, `completion_tokens` - Usage metrics
- `processing_time_ms` - Performance tracking

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Elixir 1.18.4 |
| Framework | Phoenix with LiveView |
| Database | PostgreSQL |
| ORM | Ecto |
| LLM Framework | BAML |
| LLM Model | GPT-4o-mini (OpenAI) |
| Deployment | Railway (Railpack) |
| Dev Environment | Flox |

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for comprehensive Railway deployment instructions.

**Quick Deploy:**
1. Connect GitHub repo to Railway
2. Add PostgreSQL database addon
3. Set environment variables:
   - `OPENAI_API_KEY`
   - `SECRET_KEY_BASE`
   - `PHX_HOST`
4. Railway auto-deploys on push to main

## Flox + Railpack Integration

This project uses **Flox** for local development and **Railpack** for deployment:

- **Flox** provides the complete dev environment (Elixir, PostgreSQL)
- **Railpack** reads `.tool-versions` for deployment consistency
- **`railpack.toml`** declares Rust for compiling native dependencies
- Builds `baml_elixir` from source to avoid GLIBC mismatches
- Same Elixir/Erlang versions in both environments

### Native Dependencies (The Railway Way)
Instead of precompiled binaries, we compile `baml_elixir` from source on Railway:
- `railpack.toml` declares Rust as a build dependency
- `BAML_ELIXIR_BUILD=true` forces source compilation
- No custom Dockerfile needed - pure declarative config

## Development Tools

### With Flox

```bash
flox activate              # Activate environment
flox services start        # Start PostgreSQL
flox services status       # Check service status
flox services stop         # Stop services
```

### Phoenix Commands

```bash
mix ecto.create           # Create database
mix ecto.migrate          # Run migrations
mix ecto.rollback         # Rollback migration
mix phx.server            # Start dev server
mix test                  # Run tests
mix phx.gen.secret        # Generate secret key
```

## Using Google Antigravity

This project is configured for development with [Google Antigravity](https://antigravity.google/download), an agentic development platform.

See [.claude/antigravity.md](.claude/antigravity.md) for setup instructions and project context for AI agents.

## Documentation

- [TODO.md](TODO.md) - Task tracking and progress
- [DEPLOYMENT.md](DEPLOYMENT.md) - Railway deployment guide
- [specification.md](specification.md) - Original project specification
- [FRONTEND_REFERENCE.md](FRONTEND_REFERENCE.md) - UI design inspiration
- [.claude/antigravity.md](.claude/antigravity.md) - Google Antigravity setup

## Design Philosophy

Inspired by the **Anchor** project (see `sample_code/`):
- Calm, focused interface
- Minimal cognitive load
- Clear action steps
- Real-time feedback

## Contributing

This is an MVP. Future improvements:
- Enhanced UI based on Anchor design patterns
- Profile page with submission history
- Multiple LLM model support
- Advanced customization options
- Export formats (PDF, DOCX)

## License

[Your License Here]

## Support

For issues or questions:
- Check [TODO.md](TODO.md) for known issues
- Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment troubleshooting
- Submit issues via GitHub

---

Built with ❤️ using Elixir, Phoenix, and BAML
