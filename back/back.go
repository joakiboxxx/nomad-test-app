package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/ok", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "ok")
	})

	err := http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("NOMAD_PORT_backend")), nil)
	if err != nil {
		fmt.Printf("%+v\n", err)
		os.Exit(22)
	}
}
