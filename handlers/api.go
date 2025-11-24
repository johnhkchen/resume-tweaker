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

	// Set initial loading state
	sse.MarshalAndMergeSignals(map[string]any{
		"loading": true,
		"result":  "",
		"error":   "",
		"step":    0,
	})

	// TODO: Integrate BAML client here
	// For now, simulate streaming with a placeholder
	streamResumeTweak(ctx, sse, resume, jobDesc)
}

// streamResumeTweak simulates LLM streaming with progress steps
func streamResumeTweak(ctx context.Context, sse *datastar.ServerSentEventGenerator, resume, jobDesc string) {
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
		"*This is a demo. Real AI suggestions coming soon!*",
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
