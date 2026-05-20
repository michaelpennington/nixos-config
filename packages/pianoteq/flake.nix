{
  description = "Pianoteq 9 - Physical modelling piano synthesizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        archDir =
          if system == "x86_64-linux"
          then "x86-64bit"
          else if system == "aarch64-linux"
          then "arm-64bit"
          else throw "Unsupported architecture";
      in {
        default = pkgs.stdenv.mkDerivation {
          pname = "pianoteq";
          version = "9.1.2";

          # Ask the user to provide the file manually
          src = pkgs.requireFile {
            name = "pianoteq_setup_v912.tar.xz";
            # You will replace this with the actual sha256 after you prefetch the file
            sha256 = "01pwcnxbdvyc57c5kmfr7zpc204fr75f653g6m43x0kh201bzy96";
            message = ''
              Pianoteq 9 requires a proprietary setup archive.
              1. Download 'pianoteq_setup_v912.tar.xz' from your Modartt account.
              2. Add it to your Nix store by running:
                 nix-prefetch-url file:///absolute/path/to/pianoteq_setup_v912.tar.xz
              3. Copy the resulting hash and update the 'sha256' field in this flake.nix.
            '';
          };

          # Tell Nix's unpackPhase to unpack into the current directory
          # since the archive lacks a single top-level wrapper folder.
          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
          ];

          buildInputs = with pkgs; [
            alsa-lib
            fontconfig
            freetype
            libGL
            stdenv.cc.cc.lib
            xorg.libX11
            xorg.libXext
            xorg.libXcursor
            xorg.libXinerama
            xorg.libXrandr
          ];

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall

            # Because of sourceRoot = ".", we are already at the root of the extracted archive
            cd "${archDir}"

            mkdir -p $out/bin
            cp "Pianoteq 9" $out/bin/pianoteq9

            mkdir -p $out/lib/lv2
            cp -r "Pianoteq 9.lv2" $out/lib/lv2/

            mkdir -p $out/lib/vst3
            cp -r "Pianoteq 9.vst3" $out/lib/vst3/

            runHook postInstall
          '';

          meta = with nixpkgs.lib; {
            description = "Pianoteq 9 - Physical modelling piano synthesizer";
            homepage = "https://www.modartt.com/pianoteq";
            license = licenses.unfree;
            platforms = systems;
            mainProgram = "pianoteq9";
          };
        };
      }
    );
  };
}
