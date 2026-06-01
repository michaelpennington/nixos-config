{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # PipeWire Audio Server Configuration
  services.pipewire = {
    enable = true;
    pulse.enable = true; # PulseAudio emulation
    alsa.enable = true; # ALSA emulation
  };

  # Musnix: Real-time Audio Optimizations
  musnix = {
    enable = true;
    kernel.realtime = true; # Enable the PREEMPT_RT kernel patch
  };
}
