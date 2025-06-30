{
  ...
}:
{
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # use new dbus broker instead of old bus
  services.dbus.implementation = "broker";
}
