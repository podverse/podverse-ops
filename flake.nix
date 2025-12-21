{
  description = "Homelab Kubernetes Management Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "git+https://gitea.ser.ink/Tracking/sops-nix";
  };

  outputs = { self, nixpkgs, flake-utils, sops-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # The Essentials
            kompose       # The converter
            kubectl       # The controller
            kubernetes-helm # If you move to charts later
            
            # The "Nice to Haves"
            k9s           # TUI for managing the cluster (Great in Neovim terminals)
            yamllint      # Linter for your YAML files

            # Secrets management
            sops
            moreutils
            jq
            git
            argocd
          ];

          shellHook = ''
            echo "🛠️  Homelab K3s Environment Loaded"
            echo "run 'k9s' to manage cluster or 'kompose convert' to migrate apps."
            echo "Ensure your KUBECONFIG is set (usually ~/.kube/config or /etc/rancher/k3s/k3s.yaml)"
          '';
        };
      }
    );
}
