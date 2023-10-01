FROM golang:1.21 as build_sales-api

ENV CGO_ENABLED 0
ARG BUILD_REF

COPY ./main.go /service/
COPY ./go.mod /service/
COPY ./go.sum /service/

WORKDIR /service
RUN go build -ldflags "-X main.build=${BUILD_REF}"

FROM alpine:3.18
ARG BUILD_DATE
ARG BUILD_REF

COPY --from=build_sales-api /service /service
WORKDIR /service
CMD [ "./k8s-service" ]