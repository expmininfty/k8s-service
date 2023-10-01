package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"go.uber.org/automaxprocs/maxprocs"
)

var build = "develop"

func main() {

	if _, err := maxprocs.Set(); err != nil {
		fmt.Println("maxprocs: %w\n", err)
		os.Exit(1)
	}

	g := runtime.GOMAXPROCS(0)
	log.Printf("starting service: build[%s] CPU[%d]...\n", build, g)
	defer log.Println("service ended")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	log.Println("stopping service...")
}
