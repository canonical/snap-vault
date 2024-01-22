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

### Service

Edit the configuration file at `/var/snap/vault/common/vault.hcl` and start the service with:

```shell
sudo snap start vault.vaultd
```

### Client

```shell
vault status
```
