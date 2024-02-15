ui = true

disable_mlock = true

storage "file" {
  path = "/var/snap/vault/common/data"
}

# HTTP listener
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1
}
