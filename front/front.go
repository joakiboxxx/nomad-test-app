package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type servers []struct {
	Hostname string `json:"ServiceAddress"`
	Port     uint16 `json:"ServicePort"`
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		ok, err := isbackendok()
		if err != nil {
			fmt.Printf("%+v\n", err)
			os.Exit(11)
		}

		fmt.Fprintf(w, "Backend is reachable, %d servers replying.\n", ok)
	})

	err := http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("NOMAD_PORT_frontend")), nil)
	if err != nil {
		fmt.Printf("%+v\n", err)
		os.Exit(22)
	}
}

func getbackendservers() (s servers, err error) {
	r, err := http.Get("http://consul.service.consul:8500/v1/catalog/service/backend")
	if err != nil {
		return
	}

	data, err := ioutil.ReadAll(r.Body)
	r.Body.Close()
	if err != nil {
		return
	}

	err = json.Unmarshal([]byte(data), &s)

	return
}

func isbackendok() (ok uint16, err error) {
	var servers servers

	servers, err = getbackendservers()
	if err != nil {
		return
	}

	for _, server := range servers {
		var r *http.Response

		r, err = http.Get(fmt.Sprintf("http://%s:%d/ok", server.Hostname, server.Port))
		if err != nil {
			return
		}

		var data []byte
		data, err = ioutil.ReadAll(r.Body)
		if err != nil {
			return
		}
		r.Body.Close()

		if string(data) == "ok" {
			ok++
		}
	}

	return
}
