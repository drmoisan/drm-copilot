#!/usr/bin/env bats

setup() {
	# Replace command boundaries so workspace preparation never changes real files.
	source "${BATS_TEST_DIRNAME}/../../.devcontainer/lib/workspace.sh"
	REGISTERED=/another-workspace
	READ_STATUS=0
	WRITE_STATUS=0
	MODIFY_STATUS=0
	MOUNT_ALL=0
	MOUNTED_PATH=/not-mounted
	DIRECTORY_EXISTS=0
	PYTHON_USABLE=0
	git() {
		if [[ "$*" == 'config --global --get-all safe.directory' ]]; then
			printf '%s\n' "$REGISTERED"
			return "$READ_STATUS"
		fi
		printf 'git %s\n' "$*"
		return "$WRITE_STATUS"
	}
	mountpoint() { [[ $MOUNT_ALL == 1 || $2 == "$MOUNTED_PATH" ]]; }
	id() { echo 1000; }
	sudo() {
		printf 'sudo %s\n' "$*"
		return "$MODIFY_STATUS"
	}
	find() {
		printf 'find %s\n' "$*"
		return "$MODIFY_STATUS"
	}
	rm() {
		printf 'rm %s\n' "$*"
		return "$MODIFY_STATUS"
	}
	test() {
		if [[ $1 == -d && $2 == */.venv ]]; then
			return "$DIRECTORY_EXISTS"
		elif [[ $1 == -x && $2 == */.venv/bin/python ]]; then
			return "$PYTHON_USABLE"
		fi
		builtin test "$@"
	}
}

teardown() {
	# Restore command names before the Bats framework cleans up its own output.
	unset -f git mountpoint id sudo find rm test
}

@test "Git trust adds only the exact workspace when no value exists" {
	REGISTERED=''
	READ_STATUS=1
	run trust_workspace_git '/workspace with spaces'
	[ "$status" -eq 0 ]
	[ "$output" = 'git config --global --add safe.directory /workspace with spaces' ]
}

@test "Git trust preserves an already registered workspace and other entries" {
	REGISTERED=$'/other\n/workspace\n/another'
	run trust_workspace_git /workspace
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "Git trust does not confuse a parent path with the exact workspace" {
	REGISTERED=/workspace-child
	run trust_workspace_git /workspace
	[ "$status" -eq 0 ]
	[ "$output" = 'git config --global --add safe.directory /workspace' ]
}

@test "Git configuration read errors stop setup without writing configuration" {
	READ_STATUS=128
	run trust_workspace_git /workspace
	[ "$status" -eq 128 ]
	[ -z "$output" ]
}

@test "Git configuration write failures propagate" {
	WRITE_STATUS=23
	run trust_workspace_git /workspace
	[ "$status" -eq 23 ]
}

@test "ordinary dependency directories receive no ownership changes" {
	run prepare_dependency_mounts /workspace
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "dependency mount preparation adjusts all four mount roots without recursion" {
	MOUNT_ALL=1
	run prepare_dependency_mounts /workspace
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 4 ]
	[ "${lines[0]}" = 'sudo chown 1000:1000 /workspace/.venv' ]
	[ "${lines[3]}" = 'sudo chown 1000:1000 /workspace/packages/mcp-server/node_modules' ]
	[[ "$output" != *'-R'* ]]
}

@test "dependency preparation changes only actual mount roots" {
	MOUNTED_PATH=/workspace/.venv
	run prepare_dependency_mounts /workspace
	[ "$status" -eq 0 ]
	[ "$output" = 'sudo chown 1000:1000 /workspace/.venv' ]
}

@test "an ownership failure stops before later dependency mounts" {
	MOUNT_ALL=1
	MODIFY_STATUS=19
	run prepare_dependency_mounts /workspace
	[ "$status" -eq 19 ]
	[ "${#lines[@]}" -eq 1 ]
}

@test "missing virtual environments require no cleanup" {
	DIRECTORY_EXISTS=1
	run reset_broken_workspace_venv /workspace
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "healthy virtual environments are retained" {
	run reset_broken_workspace_venv /workspace
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "broken mounted virtual environments retain the volume root" {
	PYTHON_USABLE=1
	MOUNTED_PATH=/workspace/.venv
	run reset_broken_workspace_venv /workspace
	[ "$status" -eq 0 ]
	[[ "$output" == *'find /workspace/.venv -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +'* ]]
	[[ "$output" != *$'\nrm '* ]]
}

@test "broken non-mounted environments are removed within the workspace" {
	PYTHON_USABLE=1
	run reset_broken_workspace_venv '/workspace with spaces'
	[ "$status" -eq 0 ]
	[[ "$output" == *'rm -rf -- /workspace with spaces/.venv'* ]]
}

@test "virtual environment cleanup failures propagate" {
	PYTHON_USABLE=1
	MOUNTED_PATH=/workspace/.venv
	MODIFY_STATUS=31
	run reset_broken_workspace_venv /workspace
	[ "$status" -eq 31 ]
}
