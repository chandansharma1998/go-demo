FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o go-demo .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/go-demo .

EXPOSE 8085

CMD ["./go-demo"]
