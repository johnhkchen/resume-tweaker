# Railway Deployment Guide

#deployment

This guide covers deploying the Resume Tweaker application to Railway using Railpack.

## Prerequisites

- Railway account (https://railway.com)
- GitHub repository connected to Railway
- Anthropic API key for BAML/Claude

## The Railpack Philosophy

This project uses **declarative configuration** over handwritten Dockerfiles:

- **Railpack** auto-detects Go projects via `go.mod`
- Build steps are defined in `railpack.toml`
- No custom Dockerfile needed
- Same philosophy as Nix/Arch: declare dependencies, let the platform handle it

## Deployment Steps

### 1. Connect Repository to Railway

1. Go to [Railway Dashboard](https://railway.com/new)
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Railway will auto-detect the Go project

### 2. Add PostgreSQL Database

1. In your Railway project, click "New" → "Database" → "Add PostgreSQL"
2. Railway automatically sets `DATABASE_URL`

### 3. Configure Environment Variables

Add these in the Railway dashboard:

**Required:**
```
ANTHROPIC_API_KEY=sk-ant-...
PORT=8080
```

**Optional:**
```
SESSION_SECRET=your_session_secret
```

### 4. Domain Configuration

1. In Railway project settings, go to "Settings" → "Domains"
2. Add custom domain: `resume.tweaking.app`
3. Configure DNS with CNAME record

### 5. Deploy

Push to main branch:

```bash
git push origin main
```

Railway will automatically:
1. Detect Go via `go.mod`
2. Run build phases from `railpack.toml`
3. Start the server

## Railpack Configuration

The `railpack.toml` defines the build:

```toml
[packages]
go = "1.23"
nodejs = "22"

[phases.setup]
commands = [
    "go install github.com/a-h/templ/cmd/templ@latest",
    "curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/...",
]

[phases.build]
commands = [
    "$HOME/go/bin/templ generate",
    "./tailwindcss -i ... -o ... --minify",
    "CGO_ENABLED=0 go build -o bin/server main.go",
]

[start]
command = "./bin/server"
```

## Database Migrations

After first deployment:

```bash
# Using Railway CLI
railway run psql $DATABASE_URL -f db/migrations/001_initial.sql
```

## Health Check

Railway monitors `/health` endpoint. The app returns:

```json
{"status": "healthy"}
```

## Monitoring

Railway provides:
- Application logs in dashboard
- Automatic restarts on failure
- Health check monitoring

## Troubleshooting

### Build Failures

Check Railway logs. Common issues:
- Missing environment variables
- Templ generation errors
- Tailwind CSS build errors

### Database Connection

Ensure `DATABASE_URL` is set. Check with:

```bash
railway run env | grep DATABASE
```

### LLM Errors

Verify:
- `ANTHROPIC_API_KEY` is set
- API key has sufficient credits

## Rolling Back

1. Go to "Deployments" in Railway dashboard
2. Find previous successful deployment
3. Click "Redeploy"

## Related Documents

- [[specification]] - Project requirements
- [[development]] - Local development
- [[archive/transition]] - Why we chose this stack
