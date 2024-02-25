package testgrp

import (
	"context"
	"encoding/json"
	"net/http"
)

// Test our example root
// Test is our example route.
func Test(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	// validate data
	// call into the business layer
	// return errors
	// handle ok response

	status := struct {
		Status string
	}{
		Status: "ok",
	}
	return json.NewEncoder(w).Encode(status)
}
