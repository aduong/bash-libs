#!/usr/bin/env bash

# get_certificate HOST:PORT
#
# Initiates the TLS handshake at HOST:PORT and prints the details of the certificate as well as the
# certificate to STDOUT.
get_certificate() {
  local host_port="$1"
  openssl s_client -connect "$host_port" 2> /dev/null < /dev/null \
    | perl -ne '$p=1 if /BEGIN CERTIFICATE/; print if $p; $p=0 if /END CERTIFICATE/' \
    | openssl x509 -text
}
