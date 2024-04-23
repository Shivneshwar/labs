package main

import (
	"bufio"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"math/big"
	"net"
	"os"
	"strings"
	"time"
)

const RING_SIZE_BITS = 160

type Flags struct {
	OwnIp                string
	OwnPort              int
	SecurePort           int
	JoinIp               string
	JoinPort             int
	StabilizeTime        int
	FixFingersTime       int
	CheckPredecessorTime int
	BackupTime           int
	SuccessorsCount      int
	idOverride           string
}
type Command struct {
	requiredParams int
	optionalParams int
	usageString    string
}

const (
	INVALID_INPUT_STRING = "NOT_VALID"
	INVALID_INPUT_INT    = -1
)

func main() {
	// Reading the flags
	var f Flags
	err := FlagsInit(&f)
	if err != nil {
		log.Println("error occured while reading flags: " + err.Error())
		return
	}

	logFile := fmt.Sprintf("log%v.txt", f.OwnPort)
	file, err := os.OpenFile(logFile, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, fs.FileMode.Perm(0o600))
	if err != nil {
		log.Println("log file creation failed")
		return
	}
	defer file.Close()
	var errTrunc = os.Truncate(logFile, 0)
	if errTrunc != nil {
		log.Println("log file creation failed")
		return
	}
	log.SetOutput(file)

	// Creating the ring
	initNewRing := f.InitializeRing()
	additionalId := f.GetAdditionalId()
	var additionalIdBigInt *big.Int = nil
	if additionalId != nil {
		res, err := HexStringToBytes(*additionalId)
		if err != nil {
			log.Println("error while creating additional identifier: " + err.Error())
			return
		}
		additionalIdBigInt = res
	}

	errBegin := Begin(f.OwnIp, f.OwnPort, f.SecurePort, RING_SIZE_BITS, f.SuccessorsCount, initNewRing, &f.JoinIp, &f.JoinPort, additionalIdBigInt)
	if errBegin != nil {
		log.Println("error while intializing node: " + errBegin.Error())
		return
	}

	nodeId := Get().Info.Id
	// Initialize node file system
	InitializeNodeFileSystem(nodeId.String())

	// server Initializing
	listen, err := net.Listen("tcp", ":"+fmt.Sprintf("%v", f.OwnPort))
	if err != nil {
		log.Println("error when initializing the listening socket " + err.Error())
		return
	}
	Initialize(&listen)

	// background tasks to stabilize, fix fingers and check predecessor of ring
	Schedule(Stabilize, time.Duration(f.StabilizeTime*int(time.Millisecond)))
	Schedule(FixFingers, time.Duration(f.FixFingersTime*int(time.Millisecond)))
	Schedule(CheckPredecessor, time.Duration(f.CheckPredecessorTime*int(time.Millisecond)))
	//Schedule(BackupFiles, time.Duration(f.BackupTime*int(time.Millisecond)))

	// Getting Input commmands such as Lookup, StoreFile, PrintState
	RunCommands()
}

func FlagsInit(f *Flags) error {
	flag.StringVar(&f.OwnIp, "a", INVALID_INPUT_STRING, "The IP address that the Chord client will bind to, as well as advertise to other nodes. Represented as an ASCII string (e.g., 128.8.126.63). Must be specified.")
	flag.IntVar(&f.OwnPort, "p", INVALID_INPUT_INT, "The port that the Chord client will bind to and listen on. Represented as a base-10 integer. Must be specified.")
	flag.IntVar(&f.SecurePort, "sp", INVALID_INPUT_INT, "The port on which the chord node's ssh server is listening Must be specified.")
	flag.StringVar(&f.JoinIp, "ja", INVALID_INPUT_STRING, "The IP address of the machine running a Chord node. The Chord client will join this nodes ring. Represented as an ASCII string (e.g., 128.8.126.63). Must be specified if --jp is specified.")
	flag.IntVar(&f.JoinPort, "jp", INVALID_INPUT_INT, "The port that an existing Chord node is bound to and listening on. The Chord client will join this nodes ring. Represented as a base-10 integer. Must be specified if --ja is specified.")
	flag.IntVar(&f.StabilizeTime, "ts", INVALID_INPUT_INT, "The time in milliseconds between invocations of ‘stabilize’. Represented as a base-10 integer. Must be specified, with a value in the range of [1,60000].")
	flag.IntVar(&f.FixFingersTime, "tff", INVALID_INPUT_INT, "The time in milliseconds between invocations of ‘fix fingers’. Represented as a base-10 integer. Must be specified, with a value in the range of [1,60000].")
	flag.IntVar(&f.CheckPredecessorTime, "tcp", INVALID_INPUT_INT, "The time in milliseconds between invocations of ‘check predecessor’.	Represented as a base-10 integer. Must be specified, with a value in the range of [1,60000].")
	flag.IntVar(&f.BackupTime, "tb", INVALID_INPUT_INT, "Must be specified, The time in milliseconds invocations of 'backup files', in range of [1,60000]")
	flag.IntVar(&f.SuccessorsCount, "r", INVALID_INPUT_INT, "The number of successors maintained by the Chord client. Represented as a base-10 integer. Must be specified, with a value in the range of [1,32].")
	flag.StringVar(&f.idOverride, "i", INVALID_INPUT_STRING, "The identifier (ID) assigned to the Chord client which will override the ID computed by the SHA1 sum of the clients IP address and port number. Represented as a string of 40 characters matching [0-9a-fA-F]. Optional parameter.")
	flag.Parse()
	return validateFlags(f)
}

func checkAcceptableRange(f, startRange, endRange int) bool {
	return startRange <= f && f <= endRange
}

func errorMessage(flagname, description string) string {
	return fmt.Sprintf("please set %v: %v\n", flagname, description)
}

func validateFlags(f *Flags) error {
	var errorString = ""
	if f.OwnIp == INVALID_INPUT_STRING {
		errorString += errorMessage("-a", "ASCII string of ip address to bind chord client to")
	}
	if f.OwnPort == INVALID_INPUT_INT {
		errorString += errorMessage("-p", "port number that the chord client listens on")
	}
	if f.SecurePort == INVALID_INPUT_INT {
		errorString += errorMessage("-sp", "port that the chord client's ssh server is listening on")
	}
	if (f.JoinIp == INVALID_INPUT_STRING && f.JoinPort != INVALID_INPUT_INT) || (f.JoinIp != INVALID_INPUT_STRING && f.JoinPort == INVALID_INPUT_INT) {
		var flagname string
		if f.JoinIp == INVALID_INPUT_STRING {
			flagname = "--ja"
		} else {
			flagname = "--jp"
		}
		errorString += errorMessage(flagname, "If either —ja (join address) or —jp (join port) is used, both must be given.")
	}
	if !checkAcceptableRange(f.StabilizeTime, 1, 60000) {
		errorString += errorMessage("--ts", "Runtime for the stabilize call in milliseconds, in the range [1, 60000]")
	}
	if !checkAcceptableRange(f.FixFingersTime, 1, 60000) {
		errorString += errorMessage("--tff", "Runtime for fix fingers call in milliseconds, range [1, 60000]")
	}
	if !checkAcceptableRange(f.CheckPredecessorTime, 1, 60000) {
		errorString += errorMessage("--tcp", "Runtime for predecessor call in milliseconds, in the range [1, 60000]")
	}
	if !checkAcceptableRange(f.BackupTime, 1, 60000) {
		errorString += errorMessage("--tb", "milliseconds period to run backup files call, range [1, 60000]")
	}
	if !checkAcceptableRange(f.SuccessorsCount, 1, 32) {
		errorString += errorMessage("-r", "Range of the number of successors [1, 32]")
	}
	if f.idOverride != INVALID_INPUT_STRING {
		var noOfChars = RING_SIZE_BITS / 4
		var _, err = hex.DecodeString(f.idOverride)
		if err != nil || noOfChars != len(f.idOverride) {
			errorString += errorMessage("-i", fmt.Sprintf("chord-provided hexadecimal override node identification, values: [0-9][a-f][A-F], total values: %v", noOfChars))
		}
	}
	if errorString == "" {
		return nil
	}
	return errors.New(errorString)
}

func (flag Flags) GetAdditionalId() *string {
	if flag.idOverride == INVALID_INPUT_STRING {
		return nil
	}
	return &flag.idOverride
}

// Intialize ring if join address and joinport are not provided
func (flag Flags) InitializeRing() bool {
	return flag.JoinIp == INVALID_INPUT_STRING && flag.JoinPort == INVALID_INPUT_INT
}

func FetchCommands() map[string]Command {
	return map[string]Command{
		"Lookup":     {1, 0, "usage: Lookup <filename>"},
		"StoreFile":  {1, 2, "usage: StoreFile <filepathOnDisk> [ssh: default=true, f or false to disable] encrypt file: default=true, f or false to disable]"},
		"PrintState": {0, 0, "usage: PrintState"},
	}
}

func verifyCommand(cmdArgs []string) error {
	if len(cmdArgs) <= 0 {
		return errors.New("please provide a command as an input")
	}
	cmd, ok := FetchCommands()[cmdArgs[0]]
	if !ok {
		return errors.New("command " + cmdArgs[0] + " does not exists")
	}
	//  Program is the first index, thus if there is only one parameter: Len(cmdArgs) equals 2
	if len(cmdArgs)-1 < cmd.requiredParams || len(cmdArgs)-1 > cmd.optionalParams+cmd.requiredParams {
		return errors.New(cmd.usageString)
	}
	return nil
}

func getTurnOffOption(cmdArr []string, index int) bool {
	if len(cmdArr) > index && (strings.ToLower(cmdArr[index]) == "false" || strings.ToLower(cmdArr[index]) == "f") {
		return false
	}
	return true
}

func executeCommand(cmdArr []string) {
	switch cmdArr[0] {
	case "Lookup":
		ans, err := Lookup(*GenerateHash(cmdArr[1]))
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		status, err := FetchNodeState(*ans, false, -1, nil)
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		fmt.Println(*status)
	case "StoreFile":
		ssh := getTurnOffOption(cmdArr, 2)
		encryption := getTurnOffOption(cmdArr, 3)
		node, file_Id, errStore := StoreFile(cmdArr[1], ssh, encryption)
		if errStore != nil {
			fmt.Println(errStore.Error())
			return
		}
		status, err := FetchNodeState(*node, false, -1, nil)
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		fmt.Println("Stored file successfully")
		fmt.Printf("FileId: %v\nStored at:\n%v\n", file_Id.String(), *status)
	case "PrintState":
		PrintState, err := FetchState()
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		fmt.Println(*PrintState)
	default:
		fmt.Println("command not Found")
	}
}

func RunCommands() {
	var scanner = bufio.NewReader(os.Stdin)
	for {
		fmt.Print("Chord client: ")
		args, err := scanner.ReadString('\n')
		if err != nil {
			fmt.Println("Type command in a single line.")
			continue
		}
		cmdArgs := strings.Fields(args)
		var errVerify = verifyCommand(cmdArgs)
		if errVerify != nil {
			fmt.Println(errVerify.Error())
			continue
		}
		executeCommand(cmdArgs)
	}
}

// function that passed to SchedulableTask
type SchedulableTask func()

// A new goroutine will be created, that runs the function func regularly for the duration of t.
func Schedule(function SchedulableTask, t time.Duration) {
	go func() {
		for {
			time.Sleep(t)
			function()
		}
	}()
}
