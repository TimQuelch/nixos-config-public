package main

import "github.com/TimQuelch/nixos-config/packages/hyprland-scripting/listener"

func main() {
	listener.Listen([]listener.Handler{listener.FloatBitwardenHandler})
}
