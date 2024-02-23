# Check to see if we can use ash, in Alpine images, or default to BASH.
SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)

# ==============================================================================
# CLASS NOTES
#
# Kind
# 	For full Kind v0.18 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.21.0
#
# RSA Keys
# 	To generate a private/public key PEM file.
# 	$ openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
# 	$ openssl rsa -pubout -in private.pem -out public.pem
#
# OPA Playground
# 	https://play.openpolicyagent.org/
# 	https://academy.styra.com/
# 	https://www.openpolicyagent.org/docs/latest/policy-reference/

# ==============================================================================
# Define dependencies

GOLANG          := golang:1.22
ALPINE          := alpine:3.19
KIND            := kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
POSTGRES        := postgres:16.1
GRAFANA         := grafana/grafana:10.3.0
PROMETHEUS      := prom/prometheus:v2.49.0
TEMPO           := grafana/tempo:2.3.0
LOKI            := grafana/loki:2.9.0
PROMTAIL        := grafana/promtail:2.9.0
# TELEPRESENCE    := datawire/tel2:2.13.1

KIND_CLUSTER    := ardan-starter-cluster
NAMESPACE       := sales-system
APP             := sales
BASE_IMAGE_NAME := ardanlabs/service
SERVICE_NAME    := sales-api
VERSION         := 0.0.1
SERVICE_IMAGE   := $(BASE_IMAGE_NAME)/$(SERVICE_NAME):$(VERSION)
METRICS_IMAGE   := $(BASE_IMAGE_NAME)/$(SERVICE_NAME)-metrics:$(VERSION)

# VERSION       := "0.0.1-$(shell git rev-parse --short HEAD)"

# ==============================================================================
# Install dependencies

dev-gotooling:
	go install github.com/divan/expvarmon@latest
	go install github.com/rakyll/hey@latest
	go install honnef.co/go/tools/cmd/staticcheck@latest
	go install golang.org/x/vuln/cmd/govulncheck@latest
	go install golang.org/x/tools/cmd/goimports@latest

dev-brew:
	brew update
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list pgcli || brew install pgcli
	brew list watch || brew instal watch

dev-docker:
	docker pull $(GOLANG)
	docker pull $(ALPINE)
	docker pull $(KIND)
	docker pull $(POSTGRES)
	docker pull $(GRAFANA)
	docker pull $(PROMETHEUS)
	docker pull $(TEMPO)
	docker pull $(LOKI)
	docker pull $(PROMTAIL)

# ==============================================================================
# Building containers

all: service

service:
	docker build \
		-f zarf/docker/dockerfile.service \
		-t $(SERVICE_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

# ==============================================================================
# Running from within k8s/kind

dev-bill:
# telepresence --context=kind-$(KIND_CLUSTER) helm install
# telepresence --context=kind-$(KIND_CLUSTER) connect


dev-up-local:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner
	
# kind load docker-image $(TELEPRESENCE) --name $(KIND_CLUSTER)

dev-up: dev-up-local
# telepresence --context=kind-$(KIND_CLUSTER) helm install
# telepresence --context=kind-$(KIND_CLUSTER) connect


dev-down-local:
	kind delete cluster --name $(KIND_CLUSTER)

dev-down:
# telepresence quit -s
	kind delete cluster --name $(KIND_CLUSTER)

dev-load:
	kind load docker-image $(SERVICE_IMAGE) --name $(KIND_CLUSTER)

dev-apply:
	kustomize build zarf/k8s/dev/sales | kubectl apply -f -
	kubectl wait pods --namespace=$(NAMESPACE) --selector app=$(APP) --timeout=120s --for=condition=Ready

# ------------------------------------------------------------------------------

dev-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

dev-describe-deployment:
	kubectl describe deployment --namespace=$(NAMESPACE) $(APP)

dev-describe-sales:
	kubectl describe pod --namespace=$(NAMESPACE) -l app=$(APP)

dev-restart:
	kubectl rollout restart deployment $(APP) --namespace=$(NAMESPACE)

dev-update: all dev-load dev-restart

dev-update-apply: all dev-load dev-apply

dev-logs:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(APP) --all-containers=true -f --tail=100

# ------------------------------------------------------------------------------
run-local:
	go run app/services/sales-api/main.go | go run app/tooling/logfmt/main.go

run-local-help:
	go run app/services/sales-api/main.go --help | go run app/tooling/logfmt/main.go

tidy:
	go mod tidy
	go mod vendor

# ==============================================================================
# Metrics and Tracing

metrics-view:
	expvarmon -ports="$(SERVICE_NAME).$(NAMESPACE).svc.cluster.local:4000" -vars="build,requests,goroutines,errors,panics,mem:memstats.Alloc"

metrics-view-local:
	expvarmon -ports="localhost:4000" -vars="build,requests,goroutines,errors,panics,mem:memstats.Alloc"