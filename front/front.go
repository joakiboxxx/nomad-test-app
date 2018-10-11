package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if isbackendok() {
			fmt.Fprintln(w, "Backend is OK.")
		} else {
			fmt.Fprintln(w, "Backend is NOT OK.")
		}
	})

	log.Fatal(http.ListenAndServe(":8000", nil))
}

func isbackendok() bool {
	r, err := http.Get("http://localhost:8080/ok")
	if err == nil && r.StatusCode == 200 {
		data, err := ioutil.ReadAll(r.Body)
		r.Body.Close()
		if err == nil && string(data) == "ok" {
			return true
		}
		return false
	}
	return false
}
