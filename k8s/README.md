# podverse-ops

Deployment scripts and Kubernetes manifests for the Podverse ecosystem.

## Architecture Overview

This repository uses a GitOps workflow (via ArgoCD) to manage the Podverse infrastructure on a K3s cluster.

### Layers

1.  **Infrastructure (System)**: Cluster-wide services that must exist *before* applications are deployed.
    * **Traefik**: Ingress Controller (Ports 80/443).
    * **Cert-Manager**: Automates SSL certificates via Let's Encrypt.
    * **ClusterIssuers**: Validates domain ownership (DigitalOcean/Cloudflare).
    * **StorageClass**: Local Path Provisioner (default in K3s).

2.  **Applications (Tenants)**: The actual Podverse environments.
    * **Alpha**: `podverse-alpha` namespace. Bleeding edge / Dev.
    * **Beta/Prod**: (Future) Stable environments.

## Prerequisites

Before deploying the Application manifests (in `k8s/alpha`), ensure the following Infrastructure is running:

1.  **K3s Cluster**: Up and running (e.g., on NixOS/Proxmox).
2.  **Cert-Manager**: Installed in `cert-manager` namespace.
    * *Verification*: `kubectl get pods -n cert-manager`
3.  **ClusterIssuer**: configured for your DNS provider (e.g., `letsencrypt-prod`).
    * *Verification*: `kubectl get clusterissuer letsencrypt-prod`
4.  **Secrets**:
    * Cloud Provider Tokens (e.g., `digitalocean-api-token-secret`) must be present in the `cert-manager` namespace for DNS challenges.

## Directory Structure

* `k8s/`
    * `system/`: Cluster-wide configs (Traefik defaults, etc.).
    * `alpha/`: Manifests for the Alpha environment.
        * `00-namespace.yaml`: Isolation boundary.
        * `api/`, `web/`, `db/`, `mq/`, `workers/`: Component manifests.
    * `scripts/`: Helper scripts to generate sealed secrets.

## Getting Started (Alpha Environment)

### 1. Generate Secrets

We use SOPS to encrypt secrets. Run the helper scripts in `k8s/scripts/` to generate the required encrypted files.

**Requirements Checklist:**

Before running the scripts, ensure you have the following ready:

* **Database Credentials** (`create_db_secret.sh`):
    * You will need to invent 3 passwords:
        * `POSTGRES_PASSWORD` (Superuser)
        * `POSTGRES_READ_PASSWORD` (Read-only user)
        * `POSTGRES_READ_WRITE_PASSWORD` (Application user)

* **Message Queue Credentials** (`create_mq_secret.sh`):
    * An `MQ_PASSWORD` for the admin user.

* **API Secrets** (`create_api_secret.sh`):
    * `AUTH_JWT_SECRET`: A long random string for signing tokens.
    * `MAILER_PASSWORD` (Optional): If using SMTP.

* **Worker API Keys** (`create_workers_secret.sh`):
    * `PODCAST_INDEX_AUTH_KEY`: From your PodcastIndex account.
    * `PODCAST_INDEX_SECRET_KEY`: From your PodcastIndex account.

* **Firebase Config** (`create_firebase_secret.sh`):
    * A valid `firebase-key.json` service account file on your local machine. You will be prompted for its path.

**Execution:**

```bash
# Run each script and follow the prompts
bash ./k8s/scripts/create_db_secret.sh
bash ./k8s/scripts/create_mq_secret.sh
bash ./k8s/scripts/create_api_secret.sh
bash ./k8s/scripts/create_workers_secret.sh
bash ./k8s/scripts/create_firebase_secret.sh
```


**Apply**
```bash
kubectl create namespace podverse-alpha
kubectl apply -f k8s/system/traefik-config.yaml


for file in k8s/secrets/podverse-alpha-*-opaque.enc.yaml; do
    sops -d "$file" | kubectl apply -f -
done

kubectl apply -f k8s/alpha-application.yaml

```


```fish
kubectl create namespace podverse-alpha
kubectl apply -f k8s/system/traefik-config.yaml


for file in k8s/secrets/podverse-alpha-*-opaque.enc.yaml
    sops -d $file | kubectl apply -f -
end

kubectl apply -f k8s/alpha-application.yaml


```


## Kustomize

Use Kustomize to render overlays locally, matching what ArgoCD applies. Because bases live outside the overlay folders, include the relaxed load restrictor flag.

```bash
kustomize build --load-restrictor LoadRestrictionsNone k8s/alpha/workers/
```

Other overlays render the same way (e.g., `k8s/alpha/api`, `k8s/alpha/web`, `k8s/alpha/db`). Add `| kubectl apply -f - --dry-run=client` to validate locally before pushing to Git.

## ArgoCD bootstrap (App of Apps)

- Update `repoURL` and `targetRevision` in [k8s/alpha-application.yaml](k8s/alpha-application.yaml) if deploying from a fork or different branch.
- Apply the root application once: `kubectl apply -f k8s/alpha-application.yaml`. ArgoCD will create child apps for common, api, web, db, mq, workers, and cron.
- Leave automated sync, prune, and self-heal enabled (already configured in manifests).

## Secrets and SOPS

- Encrypted secrets live under [k8s/secrets/](k8s/secrets/). Decrypt with `sops -d` when applying manually.
- Helper scripts in [k8s/scripts/](k8s/scripts/README.md) generate secrets for DB, MQ, API, workers, Firebase, and Valkey. They assume SOPS keys are available and `nix develop` provides required binaries.
- Never commit decrypted secrets; ArgoCD consumes the encrypted files directly.


# Podverse Alpha - K3s GitOps

This directory contains the Kubernetes manifests for the Podverse Alpha environment, deployed on a 3-node K3s cluster running on Proxmox/NixOS.

## Architecture: App of Apps Pattern

We utilize the **App of Apps** pattern for ArgoCD. 

Instead of manually managing individual resources (Deployments, Services, etc.) or multiple ArgoCD applications, we have one **Root Application** (`alpha-application.yaml`). This root application points to the `apps/` directory, which contains definitions for all other child applications.

**Flow:**
1.  **Root App** (`alpha-application.yaml`) syncs the `apps/` folder.
2.  **Child Apps** (e.g., `web.yaml`, `api.yaml`, `db.yaml`) appear in ArgoCD.
3.  **Resources** (Deployments, Services) defined in the component folders (e.g., `web/`, `api/`) are deployed by their respective Child Apps.

## Directory Structure

```text
k8s/
├── alpha-application.yaml      # ROOT APP: The entry point for ArgoCD
├── alpha/                      # The actual infrastructure and application code
│   ├── apps/                   # CHILD APPS: ArgoCD Application definitions
│   │   ├── api.yaml            # -> points to alpha/api
│   │   ├── common.yaml         # -> points to alpha/common
│   │   ├── db.yaml             # -> points to alpha/db
│   │   ├── web.yaml            # -> points to alpha/web
│   │   └── ... (others)
│   ├── api/                    # Manifests for API (Deployment, Service, ConfigMap)
│   ├── common/                 # Shared resources (Namespace, Ingress, TLS)
│   ├── db/                     # Database manifests
│   ├── mq/                     # Message Queue manifests
│   ├── web/                    # Frontend manifests
│   └── ...
└── system/
    └── traefik-config.yaml     # System-level config (if separate)