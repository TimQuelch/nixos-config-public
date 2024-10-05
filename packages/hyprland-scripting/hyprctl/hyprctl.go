package hyprctl

import (
	"fmt"
	"log/slog"
	"net"
	"os"
	"strings"
)

func closeConn(c net.Conn) {
	err := c.Close()
	if err != nil {
		slog.Error("failed to close socket after calling hyprctl")
	}
}

func CallHyprctlBatch(commands []string) error {
	joined := strings.Join(commands, "; ")
	batched := fmt.Sprintf("[[BATCH]]%s", joined)
	return CallHyprctl(batched)
}

func CallHyprctl(command string) error {
	socketPath := fmt.Sprintf("%s/hypr/%s/.socket.sock", os.Getenv("XDG_RUNTIME_DIR"), os.Getenv("HYPRLAND_INSTANCE_SIGNATURE"))

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		return fmt.Errorf("error connecting to hyprctl socket: %w", err)
	}
	defer closeConn(conn)

	_, err = conn.Write([]byte(command))
	if err != nil {
		return fmt.Errorf("error sending command '%s': %w", command, err)
	}

	slog.Info("called hyprctl", "command", command)

	return nil
}
