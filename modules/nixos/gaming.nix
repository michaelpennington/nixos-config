{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Minecraft Server Management (via nix-minecraft)
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      # Dedicated solo world server with custom modpack
      solo_world = let
        # Fetch modpack metadata using packwiz
        modpack = pkgs.fetchPackwizModpack {
          url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
          packHash = "sha256-/MfWEuhCzfBn/XbXVB/k2Em4XvM8SmnT71CKFfu3U+0=";
        };
        mcVersion = modpack.manifest.versions.minecraft;
        fabricVersion = modpack.manifest.versions.fabric;
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;
        # Fabric server setup with specific Java and Loader versions
        package = pkgs.fabricServers.${serverVersion}.override {
          loaderVersion = fabricVersion;
          jre_headless = pkgs.jdk25_headless;
        };
        autoStart = false;
        restart = "no";

        # Symlink mods and config from the fetched pack
        symlinks = {
          "mods" = "${modpack}/mods";
        };
        files = {
          "config" = "${modpack}/config";
        };

        # Server-specific properties
        serverProperties = {
          difficulty = "hard";
          pause-when-empty-seconds = -1;
          level-seed = 7137642459428857969;
        };

        # JVM optimizations for ZGC and memory management
        jvmOpts = "-Xms8G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:SoftMaxHeapSize=10g -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:+UseDynamicNumberOfGCThreads";
      };
    };
  };
}
