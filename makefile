SHELL := /bin/bash

run:
	go run main.go

# ==========================================
# Building containers

VERSION := 1.0

all: service

service:
	docker build \
		-f zarf/docker/Dockerfile \
		-t service-amd64:$(VERSION) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.


# ==========================================
# Running Kubernetes with KIND

KIND_CLUSTER := starter-cluster

kind-up:
	kind create cluster \
		--image kindest/node:v1.28.0 \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/kind/kind-config.yaml

kind-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

kind-load:
	kind load docker-image service-amd64:$(VERSION) --name $(KIND_CLUSTER)

kind-apply:
	kustomize build zarf/k8s/kind/service-pod | kubectl apply -f -

kind-logs:
	kubectl logs -l app=service --all-containers=true -f --tail=100 --namespace=service-system

kind-restart:
	kubectl rollout restart deployment service-pod -n service-system

kind-status-service:
	kubectl get pods -o wide --watch -n service-system

kind-update: all kind-load kind-restart

kind-describe:
	kubectl describe pod -l app=service -n service-system

kind-update-apply: all kind-load kind-apply
