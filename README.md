<a href="https://snapcraft.io/vault">
  <img alt="vault" src="https://snapcraft.io/vault/badge.svg" />
</a>

<h1 align="center">
  <img src="https://cloud.githubusercontent.com/assets/416727/24112835/03b57de4-0d58-11e7-81f5-9056cac5b427.png" alt="Vault">
  <br />
  Vault
</h1>

<p align="center"><b>This is the snap for Vault</b>, <i>"A tool for securely accessing secrets"</i>. It works on Ubuntu, Fedora, Debian, and other major Linux
distributions.</p>

## Install

    sudo snap install vault

([Don't have snapd installed?](https://snapcraft.io/docs/core/install))

## Usage

### Client

The snap provides the `vault` CLI client:

```shell
export VAULT_ADDR="http://127.0.0.1:8200"
vault status
```

### Running a local Vault server

The snap also includes a `vaultd` daemon for running a local Vault server. It is
disabled by default and will not start automatically on install.

The daemon uses the configuration at `/var/snap/vault/common/vault.hcl`, which is
populated with a default config on first install (see [Configuration](#configuration)).
Modify that file as needed, then start the daemon:

```shell
sudo snap start vault.vaultd
```

To stop or restart the daemon:

```shell
sudo snap stop vault.vaultd
sudo snap restart vault.vaultd
```

The daemon supports reload (SIGHUP) to pick up configuration changes without a full restart:

```shell
sudo snap restart --reload vault.vaultd
```

Refer to the [Vault operator commands](https://developer.hashicorp.com/vault/docs/commands/operator)
documentation for initialisation and other operations once the server is running.

## Configuration

The default `vault.hcl` at `/var/snap/vault/common/vault.hcl`:

```hcl
ui = true

disable_mlock = true

storage "file" {
  path = "/var/snap/vault/common/data"
}

# HTTP listener
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
```

| Option           | Description                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------- |
| `ui`             | Enables the built-in web UI at `http://<host>:8200/ui`                                        |
| `disable_mlock`  | Stops Vault from executing the `mlock` syscall, which prevents data swaps from memory to disk |
| `storage "file"` | Stores Vault's data on disk at `/var/snap/vault/common/data`.                                 |
| `listener "tcp"` | Listens on all interfaces on port 8200, with TLS disabled by default                          |

For advanced configuration options, refer to the [Vault configuration documentation](https://developer.hashicorp.com/vault/docs/configuration).

### Enabling TLS

To run Vault over HTTPS, replace `tls_disable = 1` in `vault.hcl` with the paths
to your certificate and key:

```hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/var/snap/vault/common/tls/vault.crt"
  tls_key_file  = "/var/snap/vault/common/tls/vault.key"
}
```

Then set `VAULT_ADDR` accordingly:

```shell
export VAULT_ADDR="https://127.0.0.1:8200"
```

See the [TCP listener documentation](https://developer.hashicorp.com/vault/docs/configuration/listener/tcp)
for the full list of TLS options.

### Environment variables

Environment variables can be set in `/var/snap/vault/common/vault.env` and will be sourced
before Vault starts.

## Further reading

- [Vault documentation](https://developer.hashicorp.com/vault/docs)
- [Vault configuration](https://developer.hashicorp.com/vault/docs/configuration)
- [Vault operator commands](https://developer.hashicorp.com/vault/docs/commands/operator)
