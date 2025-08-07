FROM golang:1.24-alpine
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o go-demo .
ENV VERSION=v1
CMD ["./go-demo"]
