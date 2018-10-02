#!/usr/bin/env bash

# gives the current kubectl context
current_context () {
	kubectl config view -o jsonpath='{.current-context}'
	echo
}

# gives the current kubectl namespace
current_namespace () {
	local cur_ctx ns
	cur_ctx="$(current_context)"
	ns="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${cur_ctx}\")].context.namespace}")"
	if [[ -z "${ns}" ]]; then
		echo "default"
	else
		echo "${ns}"
	fi
}
