# Resume Tweaker - TODO

## Completed
- [x] Scaffold Phoenix project with dependencies (baml_elixir, live_svelte, req)
- [x] Configure live_svelte and BAML in config files
- [x] Setup flox environment with PostgreSQL
- [x] Create database migrations for resumes and tweak_results tables
- [x] Run migrations: `mix ecto.create && mix ecto.migrate`
- [x] Initialize BAML project structure and define TweakResume function
  - Created `priv/baml_src/main.baml`
  - Defined data models for Resume and JobDescription
  - Defined TweakResume function with streaming support
  - Configured to use GPT-4o-mini
- [x] Implement LLM client wrapper with streaming support
  - Created `lib/resume_tweaker/llm.ex`
  - Wrapped BAML client with streaming callbacks
  - Return metadata (model, processing time)
- [x] Create Resumes context helper functions
  - Added `create_submission/3` for new submissions
  - Added `save_tweak_result/3` for saving LLM results
  - Added `get_resume_with_results!/1` for preloading
  - Added `list_resumes_by_session/1` for session tracking
- [x] Build LiveView UI with streaming output
  - Created `lib/resume_tweaker_web/live/tweak_live.ex`
  - Two textareas for resume and job description
  - Submit button with streaming support
  - Real-time output display
  - Error handling
  - Updated routes in router.ex
- [x] Test locally - server starts successfully
  - Health endpoint working at `/health`
  - Main UI accessible at `/tweak`
  - Root redirects to `/tweak`

## Pending

### Testing with LLM
- [ ] Set up environment variable for testing
  - Copy `.env.example` to `.env`
  - Add your `OPENAI_API_KEY`
  - Test actual resume tweaking with LLM streaming

### Deployment
- [ ] Prepare Railway deployment configuration
  - Environment variables setup
  - Document deployment steps
  - Test on Railway

## Notes
- Using BAML with GPT-4o-mini per specification
- Session tracking via anonymous cookies
- URL: resume.tweaking.app (subdomain deployment)
- Frontend reference: `sample_code/` contains the Anchor project for design inspiration
- Routes updated for subdomain:
  - `/` - Main interface (not `/tweak`)
  - `/profile` - User history (to be implemented)
  - `/health` - Health check
