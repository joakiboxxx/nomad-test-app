package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/ok", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "ok")
	})

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("NOMAD_PORT_backend")), nil))
}
