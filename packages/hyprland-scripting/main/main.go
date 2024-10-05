package main

import (
	"log/slog"

	"github.com/TimQuelch/nixos-config/packages/hyprland-scripting/listener"
)

func main() {
	slog.SetLogLoggerLevel(slog.LevelWarn)
	listener.Listen([]listener.Handler{listener.FloatBitwardenHandler})
}
