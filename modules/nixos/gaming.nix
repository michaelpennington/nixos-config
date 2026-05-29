{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers = {
      solo_world = let
        modpack = pkgs.fetchPackwizModpack {
          url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
          packHash = "sha256-/MfWEuhCzfBn/XbXVB/k2Em4XvM8SmnT71CKFfu3U+0=";
        };
        mcVersion = modpack.manifest.versions.minecraft;
        fabricVersion = modpack.manifest.versions.fabric;
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;
        package = pkgs.fabricServers.${serverVersion}.override {
          loaderVersion = fabricVersion;
          jre_headless = pkgs.jdk25_headless;
        };
        autoStart = false;
        restart = "no";
        symlinks = {
          "mods" = "${modpack}/mods";
        };
        serverProperties = {
          difficulty = "hard";
          pause-when-empty-seconds = -1;
          level-seed = 7137642459428857969;
        };
        files = {
          "config" = "${modpack}/config";
        };
        jvmOpts = "-Xms8G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:SoftMaxHeapSize=10g -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:+UseDynamicNumberOfGCThreads";
      };
    };
  };
}
