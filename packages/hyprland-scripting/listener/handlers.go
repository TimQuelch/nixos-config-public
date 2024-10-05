package listener

import (
	"fmt"
	"log/slog"
	"strings"

	"github.com/TimQuelch/nixos-config/packages/hyprland-scripting/hyprctl"
)

func FloatBitwardenHandler(msg HyprlandMessage) {
	if msg.Event != "windowtitlev2" {
		return
	}
	elements := strings.Split(msg.Data, ",")
	if len(elements) != 2 {
		slog.Warn("skipping invalid windowtitlev2 message", "data", msg.Data)
		return
	}
	windowId := elements[0]
	newTitle := elements[1]

	if !strings.HasPrefix(newTitle, "Extension: (Bitwarden") {
		return
	}
	slog.Info("new bitwarden window detected", "windowId", windowId, "newTitle", newTitle)

	commands := []string{
		fmt.Sprintf("dispatch setfloating address:0x%s", windowId),
		fmt.Sprintf("dispatch resizewindowpixel exact 20%% 50%%,address:0x%s", windowId),
		fmt.Sprintf("dispatch centerwindow address:0x%s", windowId),
	}

	err := hyprctl.CallHyprctlBatch(commands)
	if err != nil {
		slog.Error("Failed to call commands", "commands", commands)
	}
}
