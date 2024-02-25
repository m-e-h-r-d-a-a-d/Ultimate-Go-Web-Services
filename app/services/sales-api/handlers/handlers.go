package handlers

import (
	"net/http"
	"os"

	"github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/app/services/sales-api/handlers/v1/testgrp"
	"github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/foundation/web"
	"go.uber.org/zap"
)

// APIMuxConfig contains all the mandatory systems required by handlers.
type APIMuxConfig struct {
	Shutdown chan os.Signal
	Log      *zap.SugaredLogger
}

// APIMux constructs a http.Handler with all application routes defined.
func APIMux(cfg APIMuxConfig) *web.App {
	app := web.NewApp(cfg.Shutdown)

	app.Handle(http.MethodGet, "/test", testgrp.Test)
	return app
}
