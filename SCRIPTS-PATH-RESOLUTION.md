# Podverse Ops Scripts - Path Resolution

## Summary

All scripts in podverse-ops use dynamic path resolution to work on any machine where repos are stored in sibling folders.

## Path Resolution Pattern

All scripts follow this pattern:

```bash
# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to the base repos directory (3 levels up from scripts/)
REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Optional: Check if repos are sibling to podverse-ops
if [ ! -d "$REPOS_BASE_DIR/podverse-helpers" ]; then
  # Try going up one more level
  REPOS_BASE_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
fi
```

## Directory Structure Assumption

```
/some/path/
  ├── partytime/
  ├── podverse-admin/
  ├── podverse-ansible/
  ├── podverse-api/
  ├── podverse-external-services/
  ├── podverse-helpers/
  ├── podverse-mq/
  ├── podverse-notifications/
  ├── podverse-orm/
  ├── podverse-ops/
  │   └── scripts/
  │       ├── audit/
  │       │   └── audit-all-repos.sh
  │       ├── dev/
  │       │   └── npm-link-modules.sh
  │       ├── deploy/
  │       │   └── deploy-all-v5-alpha.sh
  │       └── publish/
  │           ├── alpha-publish-all-packages.sh
  │           └── v5-develop-update-version-all.sh
  ├── podverse-parser/
  ├── podverse-qa/
  ├── podverse-web/
  └── podverse-workers/
```

## Scripts Using Dynamic Path Resolution

### ✅ Working Scripts

1. **`scripts/audit/audit-all-repos.sh`**
   - ✅ Uses dynamic path resolution
   - ✅ Includes directory existence checks
   - ✅ Location-agnostic

2. **`scripts/dev/npm-link-modules.sh`**
   - ✅ Uses dynamic path resolution
   - ✅ Includes directory existence checks
   - ✅ Location-agnostic
   - ✅ Handles repos layouts (3 levels up)

3. **`scripts/deploy/deploy-all-v5-alpha.sh`**
   - ✅ Uses dynamic path resolution
   - ✅ Includes directory existence checks
   - ✅ Location-agnostic
   - ✅ Handles repos layouts (3 levels up)

4. **`scripts/publish/v5-develop-update-version-all.sh`**
   - ✅ Uses dynamic path resolution
   - ✅ Location-agnostic

5. **`scripts/publish/alpha-publish-all-packages.sh`**
   - ✅ Uses dynamic path resolution
   - ✅ Location-agnostic

## Usage

### From within podverse-ops directory:
```bash
# Audit all repos for vulnerabilities
./scripts/audit/audit-all-repos.sh

# Link all npm modules for development
./scripts/dev/npm-link-modules.sh

# Deploy all packages to v5-alpha
./scripts/deploy/deploy-all-v5-alpha.sh

# Update version in all packages
./scripts/publish/v5-develop-update-version-all.sh

# Publish all packages to alpha npm registry
./scripts/publish/alpha-publish-all-packages.sh
```

### From any directory:
```bash
# Use absolute paths (replace with your actual path)
/path/to/podverse-ops/scripts/audit/audit-all-repos.sh
```

## Notes

- All scripts are executable (chmod +x)
- Scripts check for directory existence before attempting operations
- Scripts will work on any machine with the standard directory structure
- Scripts include helpful error messages and progress indicators
- `npm-link-modules.sh` includes the `partytime` repo but skips it if not found
