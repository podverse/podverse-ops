{
  description = "Podverse Kubernetes Management Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      sops-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            argocd
            git
            jq
            k9s
            kompose
            kubectl
            kubernetes-helm
            libuuid
            moreutils
            pwgen
            sops
            yamllint
            yq
          ];

          shellHook = ''
            echo "🛠️  Podverse Kubernetes Management Environment"
            echo "Ensure your KUBECONFIG is set (usually ~/.kube/config or /etc/rancher/k3s/k3s.yaml)"
          '';
        };
      }
    );
}
