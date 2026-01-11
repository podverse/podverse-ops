# Database Connection Script

## Overview

The `db-connect.sh` script provides an easy way to connect to the PostgreSQL database running in your k3s cluster. It automatically:

1. Extracts credentials from the encrypted Kubernetes secret
2. Sets up a port-forward to the database service
3. Connects you to the database using `psql`
4. Cleans up the port-forward when you exit

## Prerequisites

- Access to the k3s cluster (KUBECONFIG must be set)
- SOPS encryption keys configured (to decrypt secrets)
- Run `nix develop` to ensure all tools are available (kubectl, sops, psql)

## Usage

### Connect to alpha environment (default)

```bash
./scripts/db-connect.sh
```

### Connect to a specific environment

```bash
./scripts/db-connect.sh sandbox
```

### Use a different local port

```bash
./scripts/db-connect.sh alpha 5433
```

## What it does

1. **Checks dependencies**: Verifies kubectl, sops, and psql are installed
2. **Extracts credentials**: Decrypts the secret file and extracts:
   - `POSTGRES_DB`
   - `POSTGRES_USER`
   - `POSTGRES_PASSWORD`
3. **Port-forward**: Creates a tunnel from localhost to the database service
4. **Connects**: Launches psql with the credentials
5. **Cleanup**: Automatically stops the port-forward when you exit

## Exiting

To exit the database connection:
- Press `Ctrl+D`
- Type `\q` and press Enter

The port-forward will be automatically cleaned up.

## Troubleshooting

### "Port already in use"

The script will attempt to kill any existing port-forward on the specified port. If issues persist, manually find and kill the process:

```bash
lsof -i :5432
kill <PID>
```

### "Failed to extract credentials"

Ensure your SOPS keys are properly configured and you have access to decrypt the secrets:

```bash
sops -d ./k8s/secrets/podverse-alpha-db-opaque.enc.yaml
```

### "psql is not installed"

Enter the Nix development environment which includes PostgreSQL client:

```bash
nix develop
```

## RedisInsight GUI

Use `keyvaldb-gui-connect.sh` to reach the RedisInsight dashboard that ships alongside Valkey. The script:

1. Decrypts the Valkey secret to expose `VALKEY_PASSWORD`.
2. Creates a port-forward from `localhost` to the `podverse-keyvaldb-gui` service.
3. Prints the local URL and password so you can log into RedisInsight.

### Default usage

```bash
./scripts/keyvaldb-gui-connect.sh
```

### Connect to another environment or port

```bash
./scripts/keyvaldb-gui-connect.sh sandbox 9001
```

Once the script is running open `http://localhost:<PORT>` in your browser. You can use the displayed password when the dashboard asks for the Valkey credentials. Ctrl+C stops the port-forward and exits the script.
