package testgrp

import (
	"context"
	"net/http"

	"github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/foundation/web"
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

	return web.Respond(ctx, w, status, http.StatusOK)
}
