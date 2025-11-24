# Railway Deployment Guide

This guide covers deploying the Resume Tweaker application to Railway using Railpack.

## Prerequisites

- Railway account (https://railway.com)
- GitHub repository connected to Railway
- OpenAI API key for BAML/LLM functionality

## Local Development with Flox

This project uses Flox for local environment management, which provides:
- Elixir 1.18.4
- Erlang/OTP 27
- PostgreSQL database

```bash
# Activate the Flox environment
flox activate

# Start services (PostgreSQL)
flox services start

# Run database migrations
mix ecto.create && mix ecto.migrate

# Start the Phoenix server
mix phx.server
```

## Understanding the Railpack Configuration

This project uses `railpack.toml` to solve a common deployment challenge: **native dependencies with GLIBC mismatches**.

### The Problem
- `baml_elixir` uses a Rust NIF (Native Implemented Function)
- Precompiled binaries require GLIBC 2.38
- Railway's environment has an older GLIBC version

### The Solution (The Railway/Arch Way)
Instead of writing a custom Dockerfile, we use **declarative configuration**:

```toml
# railpack.toml
[packages]
rust = "1.83"  # Install Rust during build

[build]
env = { BAML_ELIXIR_BUILD = "true" }  # Force source compilation
```

**Philosophy:**
- **Arch Linux approach**: Declare build dependencies, compile on target system
- **Railway/Railpack ethos**: Declarative config, zero handwritten Dockerfiles
- **Result**: Railpack installs Rust and compiles the NIF from source, avoiding GLIBC mismatches

This is superior to precompiled binaries because it builds against Railway's actual runtime environment.

## Deployment Steps

### 1. Connect Repository to Railway

1. Go to [Railway Dashboard](https://railway.com/new)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your `resume-tweaker` repository
4. Railway will auto-detect the Elixir/Phoenix project via `mix.exs`

### 2. Add PostgreSQL Database

1. In your Railway project, click "New" → "Database" → "Add PostgreSQL"
2. Railway will automatically set the `DATABASE_URL` environment variable

### 3. Configure Environment Variables

Add these environment variables in the Railway dashboard:

**Required:**
```
OPENAI_API_KEY=your_openai_api_key_here
SECRET_KEY_BASE=your_secret_key_base
PHX_HOST=resume.tweaking.app
PORT=8080
```

**Optional (if not using Railway defaults):**
```
DATABASE_URL=postgresql://...  (auto-set by Railway)
POOL_SIZE=10
```

#### Generate SECRET_KEY_BASE

Run locally:
```bash
mix phx.gen.secret
```

### 4. Domain Configuration

1. In Railway project settings, go to "Settings" → "Domains"
2. Add custom domain: `resume.tweaking.app`
3. Configure DNS:
   - Add a CNAME record pointing to the Railway-provided domain
   - Or use Railway's provided subdomain for testing

### 5. Deploy

Railway will automatically:
1. Detect Elixir/Phoenix via `mix.exs`
2. Use versions specified in `.tool-versions`
3. Install dependencies (`mix deps.get`)
4. Compile assets (`mix assets.deploy`)
5. Build release (`mix release`)
6. Start the application

The deployment uses the command specified in `railway.json`:
```
/app/_build/prod/rel/resume_tweaker/bin/resume_tweaker start
```

### 6. Database Migrations

After first deployment, run migrations:

```bash
# Using Railway CLI
railway run mix ecto.migrate

# Or via Railway dashboard shell
mix ecto.migrate
```

## Railpack & Flox Integration

### Version Management

Railpack automatically detects versions from `.tool-versions` file:
- This file is compatible with both `mise` and `asdf` version managers
- Railpack prioritizes this over environment variables or defaults
- The versions match those in the Flox environment for consistency

### Why This Works

1. **Local Development:** Flox provides the complete development environment
2. **Deployment:** Railpack reads `.tool-versions` and builds with matching versions
3. **Consistency:** Same Elixir/Erlang versions in both environments

## Monitoring

Railway provides:
- Application logs in the dashboard
- Health check at `/health` endpoint
- Automatic restarts on failure (configured in `railway.json`)

## Troubleshooting

### Build Failures

Check Railway logs for errors. Common issues:
- Missing environment variables
- Database migration failures
- Asset compilation errors

### Database Connection

Ensure `DATABASE_URL` is set correctly:
```elixir
# config/runtime.exs uses DATABASE_URL automatically
database_url = System.get_env("DATABASE_URL")
```

### BAML/LLM Errors

Verify:
- `OPENAI_API_KEY` is set
- BAML files are in `priv/baml_src/`
- The API key has sufficient credits

## Rolling Back

Railway keeps deployment history. To rollback:
1. Go to "Deployments" in Railway dashboard
2. Find a previous successful deployment
3. Click "Redeploy"

## Resources

- [Railpack Elixir Documentation](https://railpack.com/languages/elixir/)
- [Railway Documentation](https://docs.railway.com/)
- [Phoenix Deployment Guides](https://hexdocs.pm/phoenix/deployment.html)
