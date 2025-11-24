-- Resume Tweaker Database Schema

-- Resumes table: stores original resume submissions
CREATE TABLE IF NOT EXISTS resumes (
    id SERIAL PRIMARY KEY,
    original_content TEXT NOT NULL,
    job_description TEXT NOT NULL,
    session_id TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_resumes_session ON resumes(session_id);
CREATE INDEX IF NOT EXISTS idx_resumes_created ON resumes(created_at);

-- Tweak results table: stores LLM-generated improvements
CREATE TABLE IF NOT EXISTS tweak_results (
    id SERIAL PRIMARY KEY,
    resume_id INTEGER REFERENCES resumes(id) ON DELETE CASCADE,
    tweaked_content TEXT NOT NULL,
    model_used TEXT NOT NULL,
    prompt_tokens INTEGER,
    completion_tokens INTEGER,
    processing_time_ms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tweak_results_resume ON tweak_results(resume_id);
