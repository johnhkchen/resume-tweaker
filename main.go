package main

import (
	"log"
	"net/http"
	"os"

	"github.com/johnhkchen/resume-tweaker/handlers"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

// cookieToAuthHeader middleware reads pb_auth cookie and sets Authorization header
func cookieToAuthHeader(e *core.RequestEvent) error {
	// Check if Authorization header already exists
	if e.Request.Header.Get("Authorization") != "" {
		return e.Next()
	}

	// Try to get token from cookie
	cookie, err := e.Request.Cookie("pb_auth")
	if err == nil && cookie.Value != "" {
		e.Request.Header.Set("Authorization", cookie.Value)
	}

	return e.Next()
}

func main() {
	app := pocketbase.New()

	// Register custom routes on serve
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// Health check
		se.Router.GET("/health", func(e *core.RequestEvent) error {
			return e.JSON(http.StatusOK, map[string]string{"status": "healthy"})
		})

		// Static files
		se.Router.GET("/static/{path...}", apis.Static(os.DirFS("static"), false))

		// Public pages (rendered via Templ)
		se.Router.GET("/", handlers.HandleLandingPB)
		se.Router.GET("/login", handlers.HandleLoginPagePB)

		// Protected routes - require PocketBase auth (with cookie middleware)
		protected := se.Router.Group("/app")
		protected.BindFunc(cookieToAuthHeader)
		protected.Bind(apis.RequireAuth())
		protected.GET("/tweak", handlers.HandleTweakPagePB)
		protected.POST("/tweak/stream", handlers.HandleTweakStreamPB)

		// API routes for saving data (with cookie middleware)
		api := se.Router.Group("/api/v1")
		api.BindFunc(cookieToAuthHeader)
		api.Bind(apis.RequireAuth())
		api.POST("/resumes", handlers.HandleCreateResumePB)
		api.GET("/resumes", handlers.HandleListResumesPB)

		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
