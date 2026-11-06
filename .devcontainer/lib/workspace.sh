#!/usr/bin/env bash
# Keep workspace preparation scoped to Git trust and container dependency mounts.

trust_workspace_git() {
	# Docker Desktop exposes host ownership; trust only this exact workspace path.
	local workspace=$1 trusted status=0
	trusted=$(git config --global --get-all safe.directory) || status=$?
	if ((status > 1)); then
		return "$status"
	fi
	if [[ $'\n'$trusted$'\n' != *$'\n'"$workspace"$'\n'* ]]; then
		git config --global --add safe.directory "$workspace" || return $?
	fi
}

prepare_dependency_mounts() {
	# Change only mount-root ownership; host dependency trees and contents stay intact.
	local workspace=$1 dependency_dir
	for dependency_dir in .venv node_modules extensions/drm-copilot/node_modules packages/mcp-server/node_modules; do
		if mountpoint -q "$workspace/$dependency_dir"; then
			sudo chown "$(id -u):$(id -g)" "$workspace/$dependency_dir" || return $?
		fi
	done
}

reset_broken_workspace_venv() {
	# Preserve a Docker mount root while clearing an unusable Linux environment.
	local venv_path="$1/.venv"
	if test -d "$venv_path" && ! test -x "$venv_path/bin/python"; then
		echo "Detected broken .venv; removing and recreating its contents..."
		if mountpoint -q "$venv_path"; then
			find "$venv_path" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + || return $?
		else
			rm -rf -- "$venv_path" || return $?
		fi
	fi
}
