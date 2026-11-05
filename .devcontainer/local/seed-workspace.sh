#!/usr/bin/env bash
# Seed or refresh the named workspace volume from the read-only host checkout.
#
# The local devcontainer keeps the workspace on a named Docker volume, which
# survives "Rebuild Container". This script runs before post-create.sh and:
#   - on first create (or an interrupted seed with no HEAD), checks out the host's current
#     branch from the host repository's committed history. Untracked host
#     content (node_modules, .venv, .claude/worktrees, Windows build output)
#     is never copied, and uncommitted host changes are not carried over.
#   - on a reused volume, fetches the host's refs and fast-forwards the volume
#     when it is clean and on the same branch; otherwise it prints a warning
#     naming both commits and leaves the volume unchanged.
#
# Usage: seed-workspace.sh [HOST_DIR] [WORKSPACE_DIR]
set -euo pipefail

HOST_DIR="${1:-/workspaces/drm-copilot-host}"
WORKSPACE_DIR="${2:-/workspaces/drm-copilot}"

# The host bind mount is owned by a different uid, so git's ownership check
# must be relaxed for every command that reads it. A command-line -c setting is
# protected configuration and propagates to the upload-pack child of a fetch.
git_ws() {
	git -c safe.directory='*' -C "$WORKSPACE_DIR" "$@"
}

host_git() {
	git -c safe.directory='*' -C "$HOST_DIR" "$@"
}

fetch_host_refs() {
	git_ws fetch --quiet --prune host \
		'+refs/heads/*:refs/remotes/host/*' \
		'+refs/remotes/origin/*:refs/remotes/origin/*'
}

seed_workspace() {
	local host_branch="$1" host_head="$2" origin_url
	echo "Seeding $WORKSPACE_DIR from $HOST_DIR at ${host_branch:-detached} ($host_head)..."
	# The volume already contains the artifacts/ and data/ mount points, so
	# git clone cannot be used; initialize in place instead.
	git_ws init --quiet
	# An interrupted seed may already have configured its remotes.
	if git_ws remote get-url host >/dev/null 2>&1; then
		git_ws remote set-url host "$HOST_DIR"
	else
		git_ws remote add host "$HOST_DIR"
	fi
	origin_url="$(host_git remote get-url origin 2>/dev/null || true)"
	if [ -n "$origin_url" ] && ! git_ws remote get-url origin >/dev/null 2>&1; then
		git_ws remote add origin "$origin_url"
	fi
	fetch_host_refs
	if [ -n "$host_branch" ]; then
		# --no-track: the read-only host remote must never become the upstream.
		git_ws checkout --quiet --no-track -B "$host_branch" "refs/remotes/host/$host_branch" || return $?
		if git_ws rev-parse --verify --quiet "refs/remotes/origin/$host_branch" >/dev/null; then
			git_ws branch --quiet --set-upstream-to="origin/$host_branch" "$host_branch"
		fi
	else
		git_ws checkout --quiet --detach "$host_head" || return $?
	fi
	echo "Seeded workspace at $(git_ws rev-parse --short HEAD)."
}

refresh_workspace() {
	local host_branch="$1" host_head="$2" ws_branch ws_head
	if ! git_ws remote get-url host >/dev/null 2>&1; then
		git_ws remote add host "$HOST_DIR"
	fi
	fetch_host_refs
	ws_branch="$(git_ws symbolic-ref --quiet --short HEAD || true)"
	ws_head="$(git_ws rev-parse HEAD)"
	if [ "$ws_head" = "$host_head" ]; then
		echo "Workspace volume matches the host checkout ($(git_ws rev-parse --short HEAD))."
		return 0
	fi
	if [ -n "$host_branch" ] && [ "$ws_branch" = "$host_branch" ] &&
		[ -z "$(git_ws status --porcelain)" ] &&
		git_ws merge --quiet --ff-only "refs/remotes/host/$host_branch" >/dev/null 2>&1; then
		echo "Fast-forwarded workspace volume to the host checkout ($(git_ws rev-parse --short HEAD))."
		return 0
	fi
	echo "WARNING: the reused workspace volume differs from the host checkout and was not changed."
	echo "  volume: ${ws_branch:-detached} $(git_ws rev-parse --short HEAD)"
	echo "  host:   ${host_branch:-detached} $(git_ws rev-parse --short "$host_head")"
	echo "  Dependencies will be installed for the volume's commit. To start from the host"
	echo "  checkout, commit or push volume-only work, delete the volume, and rebuild."
}

main() {
	if ! host_git rev-parse --git-dir >/dev/null 2>&1; then
		echo "ERROR: $HOST_DIR is not a git checkout; cannot seed $WORKSPACE_DIR." >&2
		exit 1
	fi
	sudo mkdir -p "$WORKSPACE_DIR"
	sudo chown vscode:vscode "$WORKSPACE_DIR"

	local host_branch host_head
	host_branch="$(host_git symbolic-ref --quiet --short HEAD || true)"
	host_head="$(host_git rev-parse HEAD)"

	# A .git directory alone does not mean the first checkout completed.
	if git_ws rev-parse --verify --quiet 'HEAD^{commit}' >/dev/null; then
		refresh_workspace "$host_branch" "$host_head"
	else
		seed_workspace "$host_branch" "$host_head"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main "$@"
fi
