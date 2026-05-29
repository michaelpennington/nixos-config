{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  musnix = {
    enable = true;
    kernel.realtime = true;
  };
}
