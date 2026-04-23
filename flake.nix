{
  description = "claude-status — live Claude Code status line";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        claude-status = pkgs.stdenvNoCC.mkDerivation {
          pname = "claude-status";
          version = pkgs.lib.fileContents ./version.txt;
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin $out/share/claude-status
            cp -r queries $out/share/claude-status/
            cp claude-status $out/share/claude-status/
            cp -r themes $out/share/claude-status/
            chmod +x $out/share/claude-status/claude-status
            makeWrapper $out/share/claude-status/claude-status $out/bin/claude-status \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jq ]}
          '';
        };
      in
      {
        packages.default = claude-status;

        devShells.default = pkgs.mkShell {
          name = "claude-status";
          packages = with pkgs; [
            bash
            bats
            jq
          ];
        };
      }
    );
}
