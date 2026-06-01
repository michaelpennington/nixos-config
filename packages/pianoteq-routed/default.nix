{
  writeShellApplication,
  pipewire,
  pianoteq,
}:
writeShellApplication {
  name = "pianoteq";
  runtimeInputs = [pipewire];
  text = ''
    PTQ_BIN=$(find ${pianoteq}/bin -type f -executable | head -n 1)
    PIPEWIRE_LATENCY="128/48000" PIPEWIRE_QUANTUM="128/48000" "$PTQ_BIN" "$@" &
    PID=$!
    PTQ_NODE="alsa_playback.pianoteq9"
    SCARLETT_NODE="alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4G55AV578878D-00.pro-output-0"
    for _ in {1..20}; do
      if pw-link -o | grep -q "^$PTQ_NODE"; then
        break
      fi
      sleep 0.5
    done
    sleep 1
    mapfile -t PTQ_PORTS < <(pw-link -o | grep "^$PTQ_NODE")
    if [ ''${#PTQ_PORTS[@]} -ge 2 ]; then
      LEFT_OUT="''${PTQ_PORTS[0]}"
      RIGHT_OUT="''${PTQ_PORTS[1]}"
      pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX0" 2>/dev/null || true
      pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
      pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
      pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX2" 2>/dev/null || true
      pw-link "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX2"
      pw-link "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX3"
    fi
    wait $PID
  '';
}
