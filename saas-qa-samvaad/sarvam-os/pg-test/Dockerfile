FROM golang:1.24.4 AS build

WORKDIR /build
COPY . .

# DR RPO
WORKDIR /build/dr-rpo
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/dr-rpo

# HA RPO
WORKDIR /build/ha-rpo
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/ha-rpo

# RTO
WORKDIR /build/rto
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/rto

# RPO Writer
WORKDIR /build/rpo-writer
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/rpo-writer


FROM gcr.io/distroless/base-debian12
WORKDIR /app
COPY --from=build /out/* /app/
USER nonroot:nonroot