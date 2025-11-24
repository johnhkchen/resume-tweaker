package handlers

import (
	"net/http"

	"github.com/johnhkchen/resume-tweaker/templates"
)

func HandleLanding(w http.ResponseWriter, r *http.Request) {
	templates.Landing().Render(r.Context(), w)
}

func HandleTweakPage(w http.ResponseWriter, r *http.Request) {
	templates.TweakPage().Render(r.Context(), w)
}

func HandleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"healthy"}`))
}
