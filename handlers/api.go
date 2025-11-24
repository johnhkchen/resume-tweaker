package handlers

import (
	"context"
	"fmt"
	"net/http"
	"time"

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

	// Set loading state
	sse.MarshalAndMergeSignals(map[string]any{
		"loading": true,
		"result":  "",
		"error":   "",
	})

	// TODO: Integrate BAML client here
	// For now, simulate streaming with a placeholder
	streamResumeTweak(ctx, sse, resume, jobDesc)
}

// streamResumeTweak simulates LLM streaming until BAML is integrated
func streamResumeTweak(ctx context.Context, sse *datastar.ServerSentEventGenerator, resume, jobDesc string) {
	// Simulated streaming response
	chunks := []string{
		"Analyzing your resume...\n\n",
		"Based on the job description, here are improvements:\n\n",
		"**Summary:**\n",
		"• Tailored your experience to match key requirements\n",
		"• Added relevant keywords naturally\n",
		"• Quantified achievements where possible\n\n",
		"**Your Improved Resume:**\n\n",
		resume[:min(len(resume), 200)] + "...\n\n",
		"[This is a demo - BAML integration coming soon]",
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
			time.Sleep(300 * time.Millisecond) // Simulate streaming delay
		}
	}

	// Done
	sse.MarshalAndMergeSignals(map[string]any{
		"loading": false,
	})
}

func sendError(w http.ResponseWriter, r *http.Request, msg string) {
	sse := datastar.NewSSE(w, r)
	sse.MarshalAndMergeSignals(map[string]any{
		"error":   msg,
		"loading": false,
	})
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// getSessionID gets or creates a session ID from cookies
func getSessionID(r *http.Request) string {
	cookie, err := r.Cookie("session_id")
	if err != nil {
		return fmt.Sprintf("anon-%d", time.Now().UnixNano())
	}
	return cookie.Value
}
