#!/usr/bin/env bash

# removes dangling docker volumes
rm_dangling_volumes () {
	local volumes=($(docker volume ls -qf dangling=true))
	[[ ${#volumes[@]} -gt 0 ]] && docker volume rm "${volumes[@]}"
}

# removes exited docker containers
rm_exited_containers () {
	local containers=($(docker ps -qf status=exited))
	[[ ${#containers[@]} -gt 0 ]] && docker rm "${containers[@]}"
}
