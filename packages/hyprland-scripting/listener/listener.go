package listener

import (
	"fmt"
	"log/slog"
	"net"
	"os"
	"strings"
)

func readSocket(conn net.Conn) (string, error) {
	buf := make([]byte, 4096)
	n, err := conn.Read(buf)
	if err != nil {
		return "", err
	}

	return string(buf[:n]), nil
}

type HyprlandMessage struct {
	Event string
	Data  string
}

func parseSocketMessage(message string) []HyprlandMessage {
	messages := strings.Split(message, "\n")

	hyprMessages := make([]HyprlandMessage, 0, len(messages))
	for _, msg := range messages {
		if len(msg) == 0 {
			continue
		}
		elements := strings.Split(msg, ">>")
		if len(elements) != 2 {
			slog.Warn("skipping invalid message", "msg", msg)
			continue
		}
		hyprMessages = append(hyprMessages, HyprlandMessage{
			Event: elements[0],
			Data:  elements[1],
		})
	}
	return hyprMessages
}

type Handler func(msg HyprlandMessage)

func handleMessages(handlers []Handler, messages []HyprlandMessage) {
	for _, msg := range messages {
		for _, handler := range handlers {
			go handler(msg)
		}
	}
}

func Listen(handlers []Handler) {
	socketPath := fmt.Sprintf("%s/hypr/%s/.socket2.sock", os.Getenv("XDG_RUNTIME_DIR"), os.Getenv("HYPRLAND_INSTANCE_SIGNATURE"))

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	for {
		msg, err := readSocket(conn)
		if err != nil {
			slog.Error("failed to read socket message", "error", err)
			continue
		}
		msgs := parseSocketMessage(msg)
		slog.Info("received messages", "message", msg, "parsed", msgs)

		handleMessages(handlers, msgs)
	}
}

