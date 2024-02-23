package testgrp

import (
	"encoding/json"
	"net/http"
)

// Test our example root
func Test(w http.ResponseWriter, r *http.Request) {
	// validate data
	// call into the business layer
	// return errors
	// handle ok response

	status := struct {
		Status string
	}{
		Status: "ok",
	}
	json.NewEncoder(w).Encode(status)
}
