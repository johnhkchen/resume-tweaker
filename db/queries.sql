-- name: CreateResume :one
INSERT INTO resumes (original_content, job_description, session_id, metadata)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetResumeByID :one
SELECT * FROM resumes WHERE id = $1;

-- name: GetResumesBySession :many
SELECT * FROM resumes
WHERE session_id = $1
ORDER BY created_at DESC
LIMIT $2;

-- name: CreateTweakResult :one
INSERT INTO tweak_results (resume_id, tweaked_content, model_used, prompt_tokens, completion_tokens, processing_time_ms)
VALUES ($1, $2, $3, $4, $5, $6)
RETURNING *;

-- name: GetTweakResultsByResume :many
SELECT * FROM tweak_results
WHERE resume_id = $1
ORDER BY created_at DESC;

-- name: GetLatestTweakResult :one
SELECT * FROM tweak_results
WHERE resume_id = $1
ORDER BY created_at DESC
LIMIT 1;
