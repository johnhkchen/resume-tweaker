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

		// Protected routes - require PocketBase auth
		protected := se.Router.Group("/app")
		protected.Bind(apis.RequireAuth())
		protected.GET("/tweak", handlers.HandleTweakPagePB)
		protected.POST("/tweak/stream", handlers.HandleTweakStreamPB)

		// API routes for saving data
		api := se.Router.Group("/api/v1")
		api.Bind(apis.RequireAuth())
		api.POST("/resumes", handlers.HandleCreateResumePB)
		api.GET("/resumes", handlers.HandleListResumesPB)

		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
