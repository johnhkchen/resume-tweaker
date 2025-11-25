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

// setupCollections creates the resumes collection if it doesn't exist
func setupCollections(app core.App) error {
	// Check if resumes collection exists
	_, err := app.FindCollectionByNameOrId("resumes")
	if err == nil {
		log.Println("[Setup] resumes collection already exists")
		return nil
	}

	log.Println("[Setup] Creating resumes collection...")

	// Get users collection for relation
	usersCollection, err := app.FindCollectionByNameOrId("users")
	if err != nil {
		return err
	}

	// Create resumes collection
	collection := core.NewBaseCollection("resumes")

	// Add fields
	collection.Fields.Add(&core.RelationField{
		Name:          "user",
		Required:      true,
		CollectionId:  usersCollection.Id,
		MaxSelect:     1,
	})
	collection.Fields.Add(&core.TextField{
		Name:     "original_content",
		Required: true,
	})
	collection.Fields.Add(&core.TextField{
		Name:     "job_description",
		Required: true,
	})
	collection.Fields.Add(&core.TextField{
		Name:     "tweaked_content",
		Required: false,
	})

	// Set API rules - users can only access their own resumes
	collection.ListRule = ptrStr(`@request.auth.id != "" && user = @request.auth.id`)
	collection.ViewRule = ptrStr(`@request.auth.id != "" && user = @request.auth.id`)
	collection.CreateRule = ptrStr(`@request.auth.id != ""`)
	collection.UpdateRule = ptrStr(`@request.auth.id != "" && user = @request.auth.id`)
	collection.DeleteRule = ptrStr(`@request.auth.id != "" && user = @request.auth.id`)

	if err := app.Save(collection); err != nil {
		return err
	}

	log.Println("[Setup] resumes collection created successfully")
	return nil
}

func ptrStr(s string) *string {
	return &s
}

// cookieToAuthHeader middleware reads pb_auth cookie and sets Authorization header
func cookieToAuthHeader(e *core.RequestEvent) error {
	// Check if Authorization header already exists
	if e.Request.Header.Get("Authorization") != "" {
		log.Printf("[Auth] Already has Authorization header")
		return e.Next()
	}

	// Try to get token from cookie
	cookie, err := e.Request.Cookie("pb_auth")
	if err != nil {
		log.Printf("[Auth] No pb_auth cookie found: %v", err)
	} else if cookie.Value != "" {
		log.Printf("[Auth] Found pb_auth cookie, length=%d, setting Authorization header", len(cookie.Value))
		// PocketBase expects just the token, not "Bearer token"
		e.Request.Header.Set("Authorization", cookie.Value)
	}

	return e.Next()
}

func main() {
	app := pocketbase.New()

	// Run setup after app is bootstrapped (DB ready)
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// Setup collections
		if err := setupCollections(app); err != nil {
			log.Printf("[Setup] Warning: failed to setup collections: %v", err)
		}

		// Configure GitHub OAuth from env vars
		if clientId := os.Getenv("GITHUB_CLIENT_ID"); clientId != "" {
			if clientSecret := os.Getenv("GITHUB_CLIENT_SECRET"); clientSecret != "" {
				log.Println("[Setup] Configuring GitHub OAuth from env vars...")
				usersCollection, err := app.FindCollectionByNameOrId("users")
				if err == nil {
					usersCollection.OAuth2.Providers = []core.OAuth2ProviderConfig{
						{
							Name:         "github",
							ClientId:     clientId,
							ClientSecret: clientSecret,
						},
					}
					if err := app.Save(usersCollection); err != nil {
						log.Printf("[Setup] Warning: failed to configure OAuth: %v", err)
					} else {
						log.Println("[Setup] GitHub OAuth configured successfully")
					}
				}
			}
		}

		return se.Next()
	})

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
