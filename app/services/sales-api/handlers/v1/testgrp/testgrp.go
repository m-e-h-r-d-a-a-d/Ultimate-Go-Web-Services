package testgrp

import (
	"context"
	"errors"
	"math/rand"
	"net/http"

	v1 "github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/business/web/v1"
	"github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/foundation/web"
)

// Test our example root
// Test is our example route.
func Test(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	if n := rand.Intn(100); n%2 == 0 {
		return v1.NewRequestError(errors.New("TRUSTED ERROR"), http.StatusBadRequest)
	}
	// validate data
	// call into the business layer

	status := struct {
		Status string
	}{
		Status: "ok",
	}

	return web.Respond(ctx, w, status, http.StatusOK)
}
