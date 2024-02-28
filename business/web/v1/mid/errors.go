package mid

import (
	"context"
	"net/http"

	v1 "github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/business/web/v1"
	"github.com/m-e-h-r-d-a-a-d/Ultimate-Go-Web-Services/foundation/web"
	"go.uber.org/zap"
)

// Errors handles errors coming out of the call chain. It detects normal
// application errors which are used to respond to the client in a uniform way.
// Unexpected errors (status >= 500) are logged.
func Errors(log *zap.SugaredLogger) web.Middleware {
	m := func(handler web.Handler) web.Handler {
		h := func(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
			if err := handler(ctx, w, r); err != nil {
				log.Errorw("ERROR", "trace_id", web.GetTraceID(ctx), "message", err)

				var er v1.ErrorResponse
				var status int

				if err := web.Respond(ctx, w, er, status); err != nil {
					return err
				}
			}

			return nil
		}

		return h
	}

	return m
}
