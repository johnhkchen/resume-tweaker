package handlers

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	baml "github.com/johnhkchen/resume-tweaker/baml_client/baml_client"
	datastar "github.com/starfederation/datastar/sdk/go"
)

func HandleTweakStream(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Parse form
	if err := r.ParseForm(); err != nil {
		sendError(w, r, "Invalid form data")
		return
	}

	resume := r.FormValue("resume")
	jobDesc := r.FormValue("job_description")

	// Validate
	if len(resume) < 50 {
		sendError(w, r, "Please provide a longer resume (at least 50 characters)")
		return
	}
	if len(jobDesc) < 20 {
		sendError(w, r, "Please provide a longer job description (at least 20 characters)")
		return
	}

	// Start SSE
	sse := datastar.NewSSE(w, r)

	// Set initial loading state
	sse.MarshalAndMergeSignals(map[string]any{
		"loading": true,
		"result":  "",
		"error":   "",
		"step":    0,
	})

	// Check if ANTHROPIC_API_KEY is set
	if os.Getenv("ANTHROPIC_API_KEY") == "" {
		// Fall back to demo mode
		streamResumeTweakDemo(ctx, sse, resume, jobDesc)
		return
	}

	// Use BAML streaming
	streamResumeTweakBAML(ctx, sse, resume, jobDesc)
}

// streamResumeTweakBAML uses BAML to stream real LLM responses
func streamResumeTweakBAML(ctx context.Context, sse *datastar.ServerSentEventGenerator, resume, jobDesc string) {
	// Step 1: Starting LLM call
	sse.MarshalAndMergeSignals(map[string]any{"step": 1})

	// Create a channel for the streaming response
	stream, err := baml.Stream.TweakResume(ctx, resume, jobDesc)
	if err != nil {
		sse.MarshalAndMergeSignals(map[string]any{
			"error":   fmt.Sprintf("Failed to start streaming: %v", err),
			"loading": false,
			"step":    0,
		})
		return
	}

	// Step 2: Receiving response
	sse.MarshalAndMergeSignals(map[string]any{"step": 2})

	var lastContent string
	stepAdvanced := false

	// Process streaming chunks
	for value := range stream {
		select {
		case <-ctx.Done():
			return
		default:
		}

		if value.IsError {
			sse.MarshalAndMergeSignals(map[string]any{
				"error":   fmt.Sprintf("Streaming error: %v", value.Error),
				"loading": false,
				"step":    0,
			})
			return
		}

		// Advance to step 3 once we start getting content
		if !stepAdvanced {
			sse.MarshalAndMergeSignals(map[string]any{"step": 3})
			stepAdvanced = true
		}

		if value.IsFinal {
			// Final result
			if final := value.Final(); final != nil {
				lastContent = *final
			}
		} else {
			// Streaming partial result
			if partial := value.Stream(); partial != nil {
				lastContent = *partial
				sse.MarshalAndMergeSignals(map[string]any{
					"result": lastContent,
				})
			}
		}
	}

	// Step 4: Complete
	sse.MarshalAndMergeSignals(map[string]any{
		"step":    4,
		"result":  lastContent,
		"loading": false,
	})
}

// streamResumeTweakDemo is the demo/fallback mode without LLM
func streamResumeTweakDemo(ctx context.Context, sse *datastar.ServerSentEventGenerator, resume, jobDesc string) {
	// Step 1: Analyzing resume
	sse.MarshalAndMergeSignals(map[string]any{"step": 1})
	time.Sleep(800 * time.Millisecond)

	// Step 2: Parsing job requirements
	sse.MarshalAndMergeSignals(map[string]any{"step": 2})
	time.Sleep(600 * time.Millisecond)

	// Step 3: Identifying alignment opportunities
	sse.MarshalAndMergeSignals(map[string]any{"step": 3})
	time.Sleep(700 * time.Millisecond)

	// Step 4: Generating suggestions - start streaming content
	sse.MarshalAndMergeSignals(map[string]any{"step": 4})

	// Simulated streaming response with realistic content
	chunks := []string{
		"## Resume Analysis\n\n",
		"Based on the job description, I've identified several opportunities ",
		"to better align your resume with the target role.\n\n",
		"### Key Recommendations\n\n",
		"**1. Strengthen your summary**\n",
		"Your current summary is good, but consider adding specific ",
		"keywords from the job posting like:\n",
		"- Data-driven decision making\n",
		"- Cross-functional collaboration\n",
		"- Stakeholder management\n\n",
		"**2. Quantify your achievements**\n",
		"Add metrics where possible:\n",
		"- \"Increased efficiency by X%\"\n",
		"- \"Managed budget of $X\"\n",
		"- \"Led team of X people\"\n\n",
		"**3. Tailor your experience section**\n",
		"Reorder bullet points to prioritize ",
		"experiences most relevant to this role.\n\n",
		"---\n\n",
		"*Demo mode: Set ANTHROPIC_API_KEY to enable real AI suggestions.*",
	}

	var fullResult string
	for _, chunk := range chunks {
		select {
		case <-ctx.Done():
			return
		default:
			fullResult += chunk
			sse.MarshalAndMergeSignals(map[string]any{
				"result": fullResult,
			})
			time.Sleep(150 * time.Millisecond)
		}
	}

	// Done - set loading to false
	sse.MarshalAndMergeSignals(map[string]any{
		"loading": false,
	})
}

func sendError(w http.ResponseWriter, r *http.Request, msg string) {
	sse := datastar.NewSSE(w, r)
	sse.MarshalAndMergeSignals(map[string]any{
		"error":   msg,
		"loading": false,
		"step":    0,
	})
}

// getSessionID gets or creates a session ID from cookies
func getSessionID(r *http.Request) string {
	cookie, err := r.Cookie("session_id")
	if err != nil {
		return fmt.Sprintf("anon-%d", time.Now().UnixNano())
	}
	return cookie.Value
}
