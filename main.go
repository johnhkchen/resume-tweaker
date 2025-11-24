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

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatal(err)
	}
}
