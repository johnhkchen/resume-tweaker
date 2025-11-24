# Resume Tweaking App - Project Specification

## Overview

A web application that helps users improve their resumes using LLM-powered suggestions tailored to specific job descriptions. Part of the `tweaking.app` family of tools.

**Domain:** tweaking.app
**Hosting:** Railway (Hobby plan) via Railpack
**Stack:** Elixir + Phoenix + LiveView + Ecto + PostgreSQL

---

## Context

- **Existing frontend:** There's an existing HTML/JS/CSS webapp to port later. For now, build a minimal stub frontend—just enough to test the backend flow.
- **Deployment:** Use [Railpack](https://railpack.com/) instead of a custom Dockerfile. Railpack auto-detects Elixir/Phoenix projects.
- **Versions:** Use the latest stable versions of Elixir, Phoenix, LiveView, and Ecto. Don't pin to specific versions—check current releases when scaffolding.

---

## Core Requirements

### What we're building (MVP)

1. **API/backend** that accepts resume + job description, calls an LLM, returns tweaked resume
2. **Streaming responses** — tokens appear in real-time as the LLM generates them
3. **Database persistence** — store submissions and results for analytics/debugging
4. **Stub frontend** — minimal LiveView UI to test the flow (will be replaced later)

### What we're NOT building yet

- User authentication
- File upload/parsing
- Polished UI (existing frontend will be ported)
- Rate limiting
- Payments

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Elixir (latest stable) |
| Framework | Phoenix (latest stable) |
| UI | Phoenix LiveView |
| Database | PostgreSQL (via Railway addon) |
| ORM | Ecto |
| HTTP Client | Req or similar |
| Deployment | Railpack → Railway |

---

## Database Schema

Two tables:

### resumes

| Column | Type | Notes |
|--------|------|-------|
| id | primary key | |
| original_content | text | The input resume |
| job_description | text | Target job posting |
| session_id | string | Anonymous session tracking |
| metadata | map/jsonb | Optional, for extensibility |
| timestamps | utc_datetime | |

### tweak_results

| Column | Type | Notes |
|--------|------|-------|
| id | primary key | |
| resume_id | foreign key → resumes | |
| tweaked_content | text | LLM output |
| model_used | string | |
| prompt_tokens | integer | Optional |
| completion_tokens | integer | Optional |
| processing_time_ms | integer | Optional |
| timestamps | utc_datetime | |

---

## Core Modules

### 1. Resumes Context

Standard Phoenix context for resumes and tweak_results.

### 2. LLM Client

Module that:
- Builds prompt from resume + job description
- Calls LLM API with streaming
- Yields chunks via callback
- Returns metadata on completion

**Ask the user:** Which LLM framework/SDK? There's a community Elixir plugin mentioned—get details.

### 3. LiveView (Stub)

Minimal interface:
- Two textareas (resume, job description)
- Submit button
- Streaming output display
- Error handling

Don't over-invest—this gets replaced.

---

## Streaming Architecture

The key feature is streaming LLM responses to the browser.

**Pattern:**
1. User submits form
2. LiveView spawns async task for LLM call
3. LLM client sends chunks back via `send/2`
4. LiveView handles chunks in `handle_info`, updates assigns
5. Template re-renders incrementally

LiveView handles the real-time push automatically.

---

## Routes

| Path | Purpose |
|------|---------|
| `/` | Landing or redirect to /tweak |
| `/tweak` | Main interface |
| `/health` | Health check for Railway |

---

## Configuration

### Environment Variables (Railway)

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | PostgreSQL connection |
| `SECRET_KEY_BASE` | Phoenix secret |
| `ANTHROPIC_API_KEY` | Or relevant LLM key |
| `PHX_HOST` | Production hostname |
| `PORT` | Server port |

Use `config/runtime.exs` for runtime config.

---

## Deployment

Railpack auto-detects Phoenix. No Dockerfile needed.

1. Connect GitHub repo to Railway
2. Add PostgreSQL addon
3. Set environment variables
4. Push to deploy

**Reference:** https://railpack.com/

---

## Open Questions

Before building, ask the user:

1. **LLM Framework:** Which Elixir community plugin/SDK for LLM calls?

2. **Project naming:** `resume_tweaker`? Or different?

3. **URL structure:** `resume.tweaking.app` or `tweaking.app/resume`?

4. **Existing frontend:** Same repo or separate? How will it integrate?

5. **Session handling:** Anonymous cookies fine for MVP?

6. **LLM model:** Which model? Any fallback?

---

## Implementation Order (Suggested)

1. Scaffold Phoenix project
2. Set up database schema
3. Implement LLM client with streaming
4. Build stub LiveView
5. Test locally
6. Deploy to Railway via Railpack
7. Iterate based on feedback

---

## Notes

- Keep it simple—this is MVP
- Stub frontend will be replaced, don't polish it
- Streaming is the critical feature—prioritize it
- Ask for feedback often

---

*This spec is a starting point. Adapt as needed.*
