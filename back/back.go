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

	err := http.ListenAndServe(fmt.Sprintf(":%s", "8080"), nil)
	if err != nil {
		fmt.Printf("%+v\n", err)
		os.Exit(22)
	}
}
