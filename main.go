package main

import (
	"log"
	"net/http"
	"os"

	"github.com/johnhkchen/resume-tweaker/handlers"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/hook"
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
		return e.Next()
	}

	// Try to get token from cookie
	cookie, err := e.Request.Cookie("pb_auth")
	if err == nil && cookie.Value != "" {
		// PocketBase expects just the token, not "Bearer token"
		e.Request.Header.Set("Authorization", cookie.Value)
	}

	return e.Next()
}

// requireAuthWithRedirect middleware checks auth and redirects to login if not authenticated
// This must run AFTER cookieToAuthHeader so e.Auth is properly populated
func requireAuthWithRedirect(e *core.RequestEvent) error {
	// e.Auth is populated by PocketBase after cookieToAuthHeader sets the header
	if e.Auth == nil {
		return e.Redirect(http.StatusSeeOther, "/login")
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
		// Register global middleware to read pb_auth cookie and set Authorization header
		// This MUST run BEFORE PocketBase's auth token loader so e.Auth gets populated
		se.Router.Bind(&hook.Handler[*core.RequestEvent]{
			Id:       "cookieToAuth",
			Func:     cookieToAuthHeader,
			Priority: apis.DefaultLoadAuthTokenMiddlewarePriority - 1,
		})

		// Health check
		se.Router.GET("/health", func(e *core.RequestEvent) error {
			return e.JSON(http.StatusOK, map[string]string{"status": "healthy"})
		})

		// Static files
		se.Router.GET("/static/{path...}", apis.Static(os.DirFS("static"), false))

		// Public pages (rendered via Templ)
		se.Router.GET("/", handlers.HandleLandingPB)
		se.Router.GET("/login", handlers.HandleLoginPagePB)

		// Redirect old /tweak route to login (which redirects to /app/tweak if authenticated)
		se.Router.GET("/tweak", func(e *core.RequestEvent) error {
			return e.Redirect(http.StatusSeeOther, "/login")
		})

		// Logout - clear cookie and show logout page
		se.Router.GET("/logout", func(e *core.RequestEvent) error {
			// Clear pb_auth cookie
			http.SetCookie(e.Response, &http.Cookie{
				Name:     "pb_auth",
				Value:    "",
				Path:     "/",
				MaxAge:   -1,
				HttpOnly: true,
			})
			// Show logout confirmation page
			return handlers.HandleLogoutPagePB(e)
		})

		// Protected page routes - redirect to login if not authenticated
		appRoutes := se.Router.Group("/app")
		appRoutes.BindFunc(requireAuthWithRedirect) // Check if authenticated, redirect if not
		appRoutes.GET("/tweak", handlers.HandleTweakPagePB)
		appRoutes.POST("/tweak/stream", handlers.HandleTweakStreamPB)

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
