# Google Antigravity Setup

## What is Google Antigravity?

Google Antigravity is an agentic development platform that enables developers to work at a higher, task-oriented level. It uses Gemini 3's advanced reasoning, tool use, and agentic coding capabilities to transform AI assistance from a tool into an active partner.

## Key Features

- **Autonomous Agents**: AI agents have dedicated access to Code Editor, Terminal, and Browser
- **Artifacts**: Agents produce task lists, implementation plans, and screen recordings
- **Manager Surface**: Spawn and orchestrate multiple agents across different workspaces
- **Multi-Model Support**: Gemini 3 Pro, Claude Sonnet 4.5, and OpenAI GPT-OSS

## Installation

Download Google Antigravity:
- Website: https://antigravity.google/download
- Available for macOS, Windows, and Linux
- Public preview at no cost for individuals

## Opening This Project

Once Google Antigravity is installed:

1. **Open the project:**
   ```bash
   antigravity /path/to/resume-tweaker
   ```

2. **Or from within Antigravity:**
   - File → Open Folder → Select `resume-tweaker`

## Project Context for Agents

When working with agents in Google Antigravity, provide them with this context:

### Project Overview
This is a **Resume Tweaker** application built with:
- **Backend**: Elixir + Phoenix + LiveView
- **Database**: PostgreSQL (via Ecto)
- **LLM Integration**: BAML with OpenAI GPT-4o-mini
- **Deployment**: Railway via Railpack
- **Dev Environment**: Flox (local), .tool-versions (Railway)

### Key Files & Directories
```
resume-tweaker/
├── lib/
│   ├── resume_tweaker/         # Core business logic
│   │   ├── llm.ex             # BAML LLM wrapper with streaming
│   │   └── resumes/           # Database schemas & context
│   └── resume_tweaker_web/    # Web interface
│       ├── live/              # LiveView pages
│       └── router.ex          # Route definitions
├── priv/
│   ├── baml_src/              # BAML function definitions
│   ├── repo/migrations/       # Database migrations
│   └── static/                # Static assets
├── config/
│   ├── dev.exs                # Development config
│   ├── prod.exs               # Production config
│   └── runtime.exs            # Runtime config (env vars)
├── sample_code/               # Design reference (Anchor project)
└── .flox/                     # Flox environment config
```

### Important Documentation
- `TODO.md` - Current task list and progress
- `DEPLOYMENT.md` - Railway deployment guide
- `specification.md` - Original project specification
- `FRONTEND_REFERENCE.md` - UI design inspiration

### Environment Setup
```bash
# Local development with Flox
flox activate
flox services start  # Starts PostgreSQL

# Or use Railway CLI
railway link
railway run mix ecto.migrate
```

### Common Tasks

**Run the development server:**
```bash
mix phx.server
```

**Run database migrations:**
```bash
mix ecto.migrate
```

**Generate a new migration:**
```bash
mix ecto.gen.migration migration_name
```

**Test LLM integration:**
Ensure `OPENAI_API_KEY` is set in `.env`

**Deploy to Railway:**
```bash
git push origin main  # If connected to Railway
# Or use Railway CLI: railway up
```

### Testing the App

1. Start server: `mix phx.server`
2. Visit: http://localhost:4000
3. Health check: http://localhost:4000/health

### Architecture Notes

- **Streaming**: LLM responses stream in real-time via LiveView
- **Session Tracking**: Anonymous sessions via cookies
- **Database**: Two tables - `resumes` and `tweak_results`
- **Routes**: Root `/` is main interface, `/profile` (planned), `/health`

## Tips for Working with Agents

1. **Be specific**: "Update the LiveView to add a copy-to-clipboard button for the tweaked resume"
2. **Reference files**: "Check the BAML definition in priv/baml_src/main.baml"
3. **Test iteratively**: Ask agents to test changes after implementation
4. **Use artifacts**: Agents can create task lists and implementation plans

## Resources

- [Google Antigravity Documentation](https://developers.googleblog.com/build-with-google-antigravity-our-new-agentic-development-platform/)
- [Getting Started Guide](https://codelabs.developers.google.com/getting-started-google-antigravity)
- [Phoenix LiveView Docs](https://hexdocs.pm/phoenix_live_view/)
- [BAML Documentation](https://docs.boundaryml.com/)
