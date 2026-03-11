{
  description = "claude-status — live Claude Code status line";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        claude-status = pkgs.stdenvNoCC.mkDerivation {
          pname = "claude-status";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin $out/share/claude-status
            cp claude-status.jq $out/share/claude-status/
            cp claude-status.sh $out/share/claude-status/
            chmod +x $out/share/claude-status/claude-status.sh
            makeWrapper $out/share/claude-status/claude-status.sh $out/bin/claude-status \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jq ]}
          '';
        };
      in {
        packages.default = claude-status;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            jq
          ];
        };
      });
}
