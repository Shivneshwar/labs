package main

import (
	"os"
	"io"
	"net"
	"log"
	"bufio"
	"bytes"
	"net/http"
)

var serverSocket string

func main() {
	port := os.Args[1]
	serverSocket = os.Getenv("SERVER_URL")
	start(port)
}

func start(port string) {
	server, err := net.Listen("tcp", ":" + port)
	if err != nil {
		log.Fatal("Error starting server due to " + err.Error())
		return
	}
	log.Println("Server started on port " + port)
	
	var sem = make(chan int, 10)
	for {
		conn, err := server.Accept()
		if err != nil {
			log.Println("Error accepting conn due to" + err.Error())
		} else {
			sem <- 1
			go process(conn)
			<- sem
		}
	}
}

func process(conn net.Conn) {
	defer conn.Close()
	log.Println("Connection established with ", conn.RemoteAddr())
	
	reader := bufio.NewReader(conn)
	req, err := http.ReadRequest(reader)
	if err != nil {
		reply(http.StatusBadRequest, bytes.NewBufferString("Error parsing http request due to" + err.Error()), nil, conn)
		return
	}

	if req.Method == "GET" {
		proxyRequest(conn, req)
	} else {
		reply(http.StatusNotImplemented, bytes.NewBufferString("Only GET method is supported"), nil, conn)
	}
}

func proxyRequest(conn net.Conn, req *http.Request) {
	clone := req.Clone(req.Context())
	clone.URL.Scheme = "http"
	clone.RequestURI = ""
	clone.URL.Host = serverSocket
	resp, err := http.DefaultClient.Do(clone)
	if err != nil {
		log.Fatal("Error sending request to server ", err)
		reply(http.StatusInternalServerError, bytes.NewBufferString("Error sending request to server " + err.Error()), nil, conn)
	}
	resp.Write(conn)
}

func reply(code int, reader io.Reader, header http.Header, conn net.Conn) {

	var res = http.Response{
		Proto: "HTTP/1.0",
		ProtoMajor: 1,
		ProtoMinor: 0,
		Close: true,
		StatusCode: code,
		Header: header,
		Body: io.NopCloser(reader)}

	res.Write(conn)
}