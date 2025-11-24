package handlers

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func NewRouter() *chi.Mux {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RealIP)

	// Static files
	r.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Public routes
	r.Get("/", HandleLanding)
	r.Get("/health", HandleHealth)
	r.Get("/login", HandleLoginPage)
	r.Post("/login", HandleLogin)
	r.Get("/logout", HandleLogout)

	// Protected routes
	r.Group(func(r chi.Router) {
		r.Use(AuthRequired)
		r.Get("/tweak", HandleTweakPage)
		r.Post("/api/tweak/stream", HandleTweakStream)
	})

	return r
}
