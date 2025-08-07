package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	version := "1.0"
	fmt.Fprintf(w, "Hello from version %s!\n", version)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Ok")
}

func main() {
	http.HandleFunc("/", handler)
	http.HandleFunc("/health", healthCheck)
	fmt.Println("Server started on port 8085")
	http.ListenAndServe(":8085", nil)
}
