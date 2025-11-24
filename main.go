package main

import (
	"log"
	"net/http"
	"os"

	"github.com/johnhkchen/resume-tweaker/handlers"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	r := handlers.NewRouter()

	addr := "0.0.0.0:" + port
	log.Printf("Starting server on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatal(err)
	}
}
