package handlers

import (
	"bytes"
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	baml "github.com/johnhkchen/resume-tweaker/baml_client/baml_client"
	"github.com/johnhkchen/resume-tweaker/templates"
	"github.com/pocketbase/pocketbase/core"
)

// HandleLandingPB serves the landing page
func HandleLandingPB(e *core.RequestEvent) error {
	var buf bytes.Buffer
	if err := templates.Landing().Render(e.Request.Context(), &buf); err != nil {
		return e.String(http.StatusInternalServerError, "Failed to render page")
	}
	return e.HTML(http.StatusOK, buf.String())
}

// HandleLoginPagePB serves the login page (redirects to PocketBase auth)
func HandleLoginPagePB(e *core.RequestEvent) error {
	var buf bytes.Buffer
	if err := templates.LoginPage("").Render(e.Request.Context(), &buf); err != nil {
		return e.String(http.StatusInternalServerError, "Failed to render page")
	}
	return e.HTML(http.StatusOK, buf.String())
}

// HandleTweakPagePB serves the main tweak interface (protected)
func HandleTweakPagePB(e *core.RequestEvent) error {
	var buf bytes.Buffer
	if err := templates.TweakPage().Render(e.Request.Context(), &buf); err != nil {
		return e.String(http.StatusInternalServerError, "Failed to render page")
	}
	return e.HTML(http.StatusOK, buf.String())
}

// HandleTweakStreamPB handles SSE streaming for resume tweaking
func HandleTweakStreamPB(e *core.RequestEvent) error {
	ctx := e.Request.Context()

	// Parse form
	if err := e.Request.ParseForm(); err != nil {
		return e.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid form data"})
	}

	resume := e.Request.FormValue("resume")
	jobDesc := e.Request.FormValue("job_description")

	// Validate
	if len(resume) < 50 {
		return e.JSON(http.StatusBadRequest, map[string]string{"error": "Resume too short (min 50 chars)"})
	}
	if len(jobDesc) < 20 {
		return e.JSON(http.StatusBadRequest, map[string]string{"error": "Job description too short (min 20 chars)"})
	}

	// Set SSE headers
	w := e.Response
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	flusher, ok := w.(http.Flusher)
	if !ok {
		return e.JSON(http.StatusInternalServerError, map[string]string{"error": "SSE not supported"})
	}

	// Send initial state
	sendSSE(w, flusher, "signal", `{"loading":true,"result":"","error":"","step":0}`)

	// Check if ANTHROPIC_API_KEY is set
	if os.Getenv("ANTHROPIC_API_KEY") == "" {
		streamDemoMode(ctx, w, flusher)
		return nil
	}

	// Use BAML streaming
	streamBAMLMode(ctx, w, flusher, resume, jobDesc)
	return nil
}

// streamBAMLMode uses BAML to stream real LLM responses
func streamBAMLMode(ctx context.Context, w http.ResponseWriter, flusher http.Flusher, resume, jobDesc string) {
	sendSSE(w, flusher, "signal", `{"step":1}`)

	stream, err := baml.Stream.TweakResume(ctx, resume, jobDesc)
	if err != nil {
		sendSSE(w, flusher, "signal", fmt.Sprintf(`{"error":"Failed to start: %s","loading":false,"step":0}`, err.Error()))
		return
	}

	sendSSE(w, flusher, "signal", `{"step":2}`)

	var lastContent string
	stepAdvanced := false

	for value := range stream {
		select {
		case <-ctx.Done():
			return
		default:
		}

		if value.IsError {
			sendSSE(w, flusher, "signal", fmt.Sprintf(`{"error":"Stream error: %s","loading":false,"step":0}`, value.Error.Error()))
			return
		}

		if !stepAdvanced {
			sendSSE(w, flusher, "signal", `{"step":3}`)
			stepAdvanced = true
		}

		if value.IsFinal {
			if final := value.Final(); final != nil {
				lastContent = *final
			}
		} else {
			if partial := value.Stream(); partial != nil {
				lastContent = *partial
				sendSSE(w, flusher, "signal", fmt.Sprintf(`{"result":%q}`, lastContent))
			}
		}
	}

	sendSSE(w, flusher, "signal", fmt.Sprintf(`{"step":4,"result":%q,"loading":false}`, lastContent))
}

// streamDemoMode streams demo content without LLM
func streamDemoMode(ctx context.Context, w http.ResponseWriter, flusher http.Flusher) {
	sendSSE(w, flusher, "signal", `{"step":1}`)
	time.Sleep(800 * time.Millisecond)

	sendSSE(w, flusher, "signal", `{"step":2}`)
	time.Sleep(600 * time.Millisecond)

	sendSSE(w, flusher, "signal", `{"step":3}`)
	time.Sleep(700 * time.Millisecond)

	sendSSE(w, flusher, "signal", `{"step":4}`)

	chunks := []string{
		"## Resume Analysis\n\n",
		"Based on the job description, I've identified several opportunities ",
		"to better align your resume with the target role.\n\n",
		"### Key Recommendations\n\n",
		"**1. Strengthen your summary**\n",
		"- Add relevant keywords\n",
		"- Quantify achievements\n\n",
		"**2. Tailor experience section**\n",
		"- Reorder bullet points\n",
		"- Emphasize relevant skills\n\n",
		"---\n\n",
		"*Demo mode: Set ANTHROPIC_API_KEY for real AI suggestions.*",
	}

	var fullResult string
	for _, chunk := range chunks {
		select {
		case <-ctx.Done():
			return
		default:
			fullResult += chunk
			sendSSE(w, flusher, "signal", fmt.Sprintf(`{"result":%q}`, fullResult))
			time.Sleep(150 * time.Millisecond)
		}
	}

	sendSSE(w, flusher, "signal", `{"loading":false}`)
}

// sendSSE sends a server-sent event
func sendSSE(w http.ResponseWriter, flusher http.Flusher, event, data string) {
	fmt.Fprintf(w, "event: %s\ndata: %s\n\n", event, data)
	flusher.Flush()
}

// HandleCreateResumePB saves a resume to PocketBase
func HandleCreateResumePB(e *core.RequestEvent) error {
	// Get authenticated user
	auth := e.Auth
	if auth == nil {
		return e.JSON(http.StatusUnauthorized, map[string]string{"error": "Not authenticated"})
	}

	// Parse request body
	var data struct {
		OriginalContent string `json:"original_content"`
		JobDescription  string `json:"job_description"`
		TweakedContent  string `json:"tweaked_content"`
	}
	if err := e.BindBody(&data); err != nil {
		return e.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}

	// Create record in "resumes" collection
	collection, err := e.App.FindCollectionByNameOrId("resumes")
	if err != nil {
		return e.JSON(http.StatusInternalServerError, map[string]string{"error": "Collection not found"})
	}

	record := core.NewRecord(collection)
	record.Set("user", auth.Id)
	record.Set("original_content", data.OriginalContent)
	record.Set("job_description", data.JobDescription)
	record.Set("tweaked_content", data.TweakedContent)

	if err := e.App.Save(record); err != nil {
		return e.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to save"})
	}

	return e.JSON(http.StatusCreated, map[string]any{
		"id":      record.Id,
		"created": record.GetDateTime("created"),
	})
}

// HandleListResumesPB lists user's saved resumes
func HandleListResumesPB(e *core.RequestEvent) error {
	auth := e.Auth
	if auth == nil {
		return e.JSON(http.StatusUnauthorized, map[string]string{"error": "Not authenticated"})
	}

	records, err := e.App.FindRecordsByFilter(
		"resumes",
		"user = {:userId}",
		"-created",
		10,
		0,
		map[string]any{"userId": auth.Id},
	)
	if err != nil {
		return e.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to fetch resumes"})
	}

	var result []map[string]any
	for _, r := range records {
		result = append(result, map[string]any{
			"id":              r.Id,
			"original_content": r.GetString("original_content"),
			"job_description": r.GetString("job_description"),
			"tweaked_content": r.GetString("tweaked_content"),
			"created":         r.GetDateTime("created"),
		})
	}

	return e.JSON(http.StatusOK, result)
}
