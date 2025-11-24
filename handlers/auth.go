package handlers

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/hex"
	"net/http"
	"os"
	"time"

	"github.com/johnhkchen/resume-tweaker/templates"
)

const (
	authCookieName = "auth_token"
	cookieMaxAge   = 7 * 24 * 60 * 60 // 7 days
)

var authPassword string
var authToken string

func init() {
	authPassword = os.Getenv("AUTH_PASSWORD")
	// Generate a random token for this server instance
	tokenBytes := make([]byte, 32)
	rand.Read(tokenBytes)
	authToken = hex.EncodeToString(tokenBytes)
}

// AuthRequired middleware checks if user is authenticated
func AuthRequired(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// If no password is set, allow all requests (dev mode)
		if authPassword == "" {
			next.ServeHTTP(w, r)
			return
		}

		// Check for valid auth cookie
		cookie, err := r.Cookie(authCookieName)
		if err != nil || !isValidToken(cookie.Value) {
			// Redirect to login page
			http.Redirect(w, r, "/login", http.StatusSeeOther)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// IsAuthenticated checks if the current request is authenticated
func IsAuthenticated(r *http.Request) bool {
	if authPassword == "" {
		return true
	}
	cookie, err := r.Cookie(authCookieName)
	if err != nil {
		return false
	}
	return isValidToken(cookie.Value)
}

func isValidToken(token string) bool {
	return subtle.ConstantTimeCompare([]byte(token), []byte(authToken)) == 1
}

// HandleLoginPage renders the login form
func HandleLoginPage(w http.ResponseWriter, r *http.Request) {
	// If already authenticated, redirect to tweak
	if IsAuthenticated(r) {
		http.Redirect(w, r, "/tweak", http.StatusSeeOther)
		return
	}

	// Check for error query param
	errorMsg := ""
	if r.URL.Query().Get("error") == "1" {
		errorMsg = "Invalid password. Please try again."
	}

	templates.LoginPage(errorMsg).Render(r.Context(), w)
}

// HandleLogin processes the login form
func HandleLogin(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		http.Redirect(w, r, "/login?error=1", http.StatusSeeOther)
		return
	}

	password := r.FormValue("password")

	// Check password using constant-time comparison
	if subtle.ConstantTimeCompare([]byte(password), []byte(authPassword)) != 1 {
		http.Redirect(w, r, "/login?error=1", http.StatusSeeOther)
		return
	}

	// Set auth cookie
	http.SetCookie(w, &http.Cookie{
		Name:     authCookieName,
		Value:    authToken,
		Path:     "/",
		MaxAge:   cookieMaxAge,
		HttpOnly: true,
		Secure:   r.TLS != nil || r.Header.Get("X-Forwarded-Proto") == "https",
		SameSite: http.SameSiteLaxMode,
	})

	// Redirect to tweak page
	http.Redirect(w, r, "/tweak", http.StatusSeeOther)
}

// HandleLogout clears the auth cookie
func HandleLogout(w http.ResponseWriter, r *http.Request) {
	http.SetCookie(w, &http.Cookie{
		Name:     authCookieName,
		Value:    "",
		Path:     "/",
		MaxAge:   -1,
		Expires:  time.Unix(0, 0),
		HttpOnly: true,
	})

	http.Redirect(w, r, "/", http.StatusSeeOther)
}
