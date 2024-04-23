FROM golang:1.16-alpine

WORKDIR /app

COPY go.mod main.go ./

RUN go mod download && go build -o proxy

EXPOSE 8081

CMD ["./proxy", "8081"]
