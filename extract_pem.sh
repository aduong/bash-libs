#!/usr/bin/env bash

# extracts PEM-formatted data from stdin
extract_certs() {
  perl -ne 'if (/^-{5}BEGIN .+-{5}$/) { $p=1 } print if $p; if (/^-{5}END .+-{5}$/) { $p=0 }'
}
