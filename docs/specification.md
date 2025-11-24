# Resume Tweaker - Product Specification

#architecture #reference

## Overview

A web application that helps users improve their resumes using LLM-powered suggestions tailored to specific job descriptions. Part of the `tweaking.app` family of tools.

- **Domain**: resume.tweaking.app
- **Hosting**: Railway via Railpack
- **Dev Environment**: Flox

## Stack

| Layer | Technology |
|-------|------------|
| Language | Go |
| Router | Chi |
| Templates | Templ |
| Interactivity | Datastar |
| Styling | Tailwind CSS + Anchor Sage & Slate |
| LLM | BAML |
| Database | PostgreSQL + sqlc |
| Deploy | Railpack → Railway |
| Dev Environment | Flox |

## Why This Stack

| Choice | Reason |
|--------|--------|
| **Go** | First-class BAML support, static binaries, cheap on Railway |
| **Datastar** | SSE-native, perfect for streaming LLM responses |
| **Templ** | Type-safe HTML templates, compile-time checks |
| **BAML** | Type-safe LLM interactions, structured outputs |
| **sqlc** | Type-safe SQL, generated Go code |
| **Tailwind + Anchor** | Sage & Slate palette, dark mode, consistent design |
| **Flox** | Reproducible dev environment |
| **Railpack** | Zero-config deploys for Go |

## Core Feature: Streaming LLM Responses

The critical UX is streaming - tokens appear as the LLM generates them.

**Flow:**
1. User submits resume + job description
2. Server calls BAML streaming API
3. Server sends SSE chunks to browser
4. Datastar updates DOM reactively
5. Final result displayed, saved to DB

**Progress Steps:**
1. Analyzing your resume
2. Parsing job requirements
3. Identifying alignment opportunities
4. Generating suggestions

## Authentication

### Phase 1: Shared Password (Current)
- `AUTH_PASSWORD` env var protects `/tweak` and `/api/tweak/stream`
- 7-day cookie session
- Constant-time password comparison
- No auth when env var is unset (dev mode)

### Phase 2: OAuth (Future)
- Google OAuth for real user accounts
- Per-user rate limiting
- User history and saved resumes

## Database Schema

### resumes

```sql
CREATE TABLE resumes (
    id SERIAL PRIMARY KEY,
    original_content TEXT NOT NULL,
    job_description TEXT NOT NULL,
    session_id TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### tweak_results

```sql
CREATE TABLE tweak_results (
    id SERIAL PRIMARY KEY,
    resume_id INTEGER REFERENCES resumes(id) ON DELETE CASCADE,
    tweaked_content TEXT NOT NULL,
    model_used TEXT NOT NULL,
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    processing_time_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## BAML Definition

See `docs/reference/anchor/baml_src/resume.baml` for reference implementation.

```baml
function TweakResume(resume: string, job_description: string) -> string {
    client "anthropic/claude-sonnet-4-20250514"

    prompt #"
        You are an expert resume consultant. Improve the given resume
        to better match the target job description.

        Guidelines:
        - Tailor content to job requirements
        - Use relevant keywords naturally
        - Quantify achievements where possible
        - Improve clarity and impact
        - Maintain honesty - don't fabricate

        ## Resume
        {{ resume }}

        ## Job Description
        {{ job_description }}

        ## Instructions
        Output ONLY the improved resume. No explanations.
    "#
}
```

## Routes

| Path | Method | Auth | Purpose |
|------|--------|------|---------|
| `/` | GET | Public | Landing page |
| `/login` | GET | Public | Login form |
| `/login` | POST | Public | Authenticate |
| `/logout` | GET | Public | Clear session |
| `/tweak` | GET | Protected | Main interface |
| `/api/tweak/stream` | POST | Protected | SSE streaming endpoint |
| `/health` | GET | Public | Health check for Railway |

## Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `PORT` | Yes (Railway sets) | Server port |
| `AUTH_PASSWORD` | Production | Password protection |
| `DATABASE_URL` | Future | PostgreSQL connection |
| `ANTHROPIC_API_KEY` | Future | For BAML/Claude |

## Design System

Using Anchor's Sage & Slate palette:

| Token | Light | Dark |
|-------|-------|------|
| `--color-paper` | #F9F9F7 | #222831 |
| `--color-card` | #FFFFFF | #393E46 |
| `--color-sage` | #6B9080 | #8FAF9A |
| `--color-slate` | #2D3748 | #DFD0B8 |

Fonts: Lora (serif headings) + Nunito (sans body)

## Related Documents

- [[deployment]] - How to deploy to Railway
- [[development]] - Local development setup
- [[reference/anchor]] - BAML prompts and UI patterns from Anchor
