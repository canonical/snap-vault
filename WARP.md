# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Repository purpose: Snap packaging for HashiCorp Vault, including a daemonized service, default configs, and CI to build/publish and smoke-test the snap.

Commonly used commands
- Prerequisites on Fedora (snapd + snapcraft):
  sudo dnf install -y snapd
  sudo systemctl enable --now snapd.socket
  sudo ln -s /var/lib/snapd/snap /snap || true
  sudo snap install snapcraft --classic

- Helper variables (avoid hardcoding):
  SNAP_NAME=$(awk '/^name:/{print $2}' snap/snapcraft.yaml)

- Build the snap (per CONTRIBUTING.md):
  snapcraft pack --verbose
  # Alternative full build (if you haven’t staged parts yet):
  # snapcraft

- Install or refresh the locally built snap:
  SNAP_FILE=$(ls -t ./*.snap | head -n1)
  sudo snap install --dangerous "$SNAP_FILE"

- Service lifecycle (daemon app is `${SNAP_NAME}.vaultd`):
  sudo snap start  "$SNAP_NAME.vaultd"
  sudo snap stop   "$SNAP_NAME.vaultd"
  sudo snap restart "$SNAP_NAME.vaultd"

- Check service status and logs:
  snap services "$SNAP_NAME"
  snap logs "$SNAP_NAME.vaultd" --follow

- Client usage (CLI app is `${SNAP_NAME}.vault`):
  export VAULT_ADDR=http://127.0.0.1:8200
  snap run "$SNAP_NAME.vault" --version
  snap run "$SNAP_NAME.vault" status
  # Optional local health probe
  curl -s http://127.0.0.1:8200/v1/sys/health | jq .

- Configuration locations:
  # Defaults are copied on first install by the install hook
  # Edit the active config in $SNAP_COMMON (preserved across refreshes)
  sudoedit "/var/snap/${SNAP_NAME}/common/vault.hcl"
  sudoedit "/var/snap/${SNAP_NAME}/common/vault.env"

Architecture and structure overview
- snap/snapcraft.yaml
  - Packaging definition for the "vault" snap.
  - Base: core24; Confinement: strict; Multi-arch: amd64, arm64, armhf, ppc64el, s390x.
  - Parts:
    - vault (plugin: go) builds upstream hashicorp/vault at tag v${SNAPCRAFT_PROJECT_VERSION}.
      - Build tags: vault, ui.
      - UI assets are built when supported (make static-dist is invoked in override-build).
      - Node/Yarn repos are configured to support the UI build.
  - Apps:
    - vault: CLI entrypoint (command: bin/vault; plugs: network, network-bind, home).
    - vaultd: daemonized service controlled via service/bin scripts (start/reload/stop), plugs: network, network-bind.

- service/
  - bin/
    - vaultd-start: sources "$SNAP_COMMON"/vault.env and launches `vault server -config "$SNAP_COMMON"/vault.hcl`.
    - vaultd-reload: SIGHUP the vault process.
    - vaultd-stop: SIGTERM the vault process.
  - vault.hcl, vault.env: default runtime config/env copied to $SNAP_COMMON on first install.

- snap/hooks/install
  - Copies default vault.hcl and vault.env from the snap payload into $SNAP_COMMON so local edits persist across refreshes.

- CI/CD (.github/workflows/)
  - master.yml: Builds the snap, publishes to the Snap Store on protected branches, then smoke-tests the service (verifies port 8200 is listening).
  - auto-update.yml: Detects latest upstream Vault tag, bumps snap/snapcraft.yaml version, and opens an automated PR.
  - lint-pr.yaml: Semantic pull request title check.
  - dependabot_pr.yaml: Auto-approve and enable auto-merge for Dependabot PRs.
  - jira-sync.yaml: Syncs GitHub issues to JIRA.
  - identify-kevs.yaml: Scheduled KEV identification via a shared workflow.

- Documentation
  - README.md: End-user install and usage basics (snap install vault; service start; vault status).
  - CONTRIBUTING.md: Local packaging command: `snapcraft pack --verbose`.

Notes for Fedora Linux environments
- Use snapd and snapcraft as above. If snapcraft prompts to set up/initialize LXD for building core24 snaps, accept the prompts.
- No Docker is required; Podman is not needed for this workflow.

