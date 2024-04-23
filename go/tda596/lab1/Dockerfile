FROM golang:1.16-alpine

WORKDIR /app

COPY go.mod main.go ./

RUN go mod download && go build -o http_server

EXPOSE 8080

CMD ["./http_server", "8080"]
