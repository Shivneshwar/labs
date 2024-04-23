package main

import (
	"os"
	"io"
	"net"
	"log"
	"bufio"
	"bytes"
	"strings"
	"net/http"
	"mime/multipart"
)

func main() {
	port := os.Args[1]
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
		handleGet(conn, req)
	} else if req.Method == "POST" { 
		flag, msg := handlePost(req)
		if flag {
			reply(http.StatusCreated, bytes.NewBufferString(msg), nil, conn)
		} else {
			reply(http.StatusBadRequest, bytes.NewBufferString(msg), nil, conn)
		}
	} else {
		reply(http.StatusNotImplemented, bytes.NewBufferString("Only GET and POST methods are supported"), nil, conn)
	}
}

func handleGet(conn net.Conn, req *http.Request) {
	url := req.URL.Path
	splitUrl := strings.Split(url, "/")
	fileName := splitUrl[len(splitUrl)-1]
	log.Println("Handling GET for URL " + url)
	
	if fileName != "" {
		splitFileName := strings.Split(fileName, ".")
		ext := splitFileName[len(splitFileName)-1]
		var allowed = []string{"html", "txt", "gif", "jpeg", "jpg", "css"}
		if !contains(allowed, ext) {
			reply(http.StatusBadRequest, bytes.NewBufferString("Illegal file extension"), nil, conn)
			return
		}

		file, err := os.ReadFile(fileName)
		if err != nil {
			msg := "Error reading file " + fileName + " due to " + err.Error()
			log.Println(msg)
			reply(http.StatusNotFound, bytes.NewBufferString(msg), nil, conn)
			return
		} else {
			header := make(http.Header)
			header.Set("Content-Type", http.DetectContentType(file))
			reply(http.StatusOK, bytes.NewBuffer(file), header, conn)
		}
	} else {
		reply(http.StatusNotFound, bytes.NewBufferString("Please enter correct file name/url"), nil, conn)
	}
}

func handlePost(req *http.Request) (bool, string) {
	log.Println("Handling POST for URL " + req.URL.Path)
	
	reader, err := req.MultipartReader()
	if err != nil {
		log.Println(err)
		return false, "Upload failed due to " + err.Error()
	}
	
	for {	
		part, err := reader.NextPart()	
		if err == io.EOF {
			break
		} else if err != nil {
			log.Println(err)
			return false, "Upload failed due to " + err.Error()
		}

		defer func(part *multipart.Part) {
			err := part.Close()
			if err != nil {
				log.Println(err)
				return
			}
		}(part)
		
		if part.FileName() == "" {
			continue
		}

		file, err := os.Create(part.FileName())
		if err != nil {
			log.Println(err)
			return false, "Upload failed due to failure in opening file Error: " + err.Error()
		}
		defer func(file *os.File) {
			err := file.Close()
			if err != nil {
				return
			}
		}(file)
		_, err = io.Copy(file, part)
		if err != nil {
			log.Println(err)
			return false, "Upload failed due to failure in writing to file Error: " + err.Error()
		}
	}
	return true, "File uploaded"
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

func contains(s []string, str string) bool {
	for _, v := range s {
		if v == str {
			return true
		}
	}
	return false
}
