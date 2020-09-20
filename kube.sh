#!/usr/bin/env bash

# gives the current kubectl context
current_context() {
  kubectl config view -o jsonpath='{.current-context}'
  echo
}

# gives the current kubectl namespace
current_namespace() {
  local cur_ctx ns
  cur_ctx="$(current_context)"
  ns="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${cur_ctx}\")].context.namespace}")"
  if [[ -z "${ns}" ]]; then
    echo "default"
  else
    echo "${ns}"
  fi
}

k_top_for_node() {
  local node=$1
  kubectl top po -A \
    | grep --color=never -f <(
      k get po --field-selector=spec.nodeName="$node" -o custom-columns=:metadata.namespace,:metadata.name --no-headers -A
    )
}
