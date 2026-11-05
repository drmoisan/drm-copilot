#!/usr/bin/env bats

setup() {
	# Source without executing setup, and replace all external operations with fakes.
	source "${BATS_TEST_DIRNAME}/../../.devcontainer/local/seed-workspace.sh"
	HOST_DIR=/host
	WORKSPACE_DIR=/workspace
	host_git() {
		case "$*" in
		'rev-parse --git-dir') return 0 ;;
		'symbolic-ref --quiet --short HEAD') echo main ;;
		'rev-parse HEAD') echo host-commit ;;
		'remote get-url origin') echo https://example.invalid/repo.git ;;
		*) return 1 ;;
		esac
	}
	sudo() { :; }
}

@test "workspace without HEAD resumes seeding instead of refreshing" {
	git_ws() { return 1; }
	seed_workspace() { echo "seed $*"; }
	refresh_workspace() { echo unexpected-refresh; }
	run main
	[ "$status" -eq 0 ]
	[[ "$output" == 'seed main host-commit' ]]
}

@test "workspace with a valid HEAD uses the existing refresh path" {
	git_ws() { [[ "$*" == "rev-parse --verify --quiet HEAD^{commit}" ]]; }
	seed_workspace() { echo unexpected-seed; }
	refresh_workspace() { echo "refresh $*"; }
	run main
	[ "$status" -eq 0 ]
	[[ "$output" == 'refresh main host-commit' ]]
}

@test "interrupted seed reuses existing remotes and completes checkout" {
	git_ws() {
		case "$*" in
		'remote add '*)
			echo unexpected-add
			return 1
			;;
		'rev-parse --short HEAD') echo host-commit ;;
		*) echo "$*" ;;
		esac
	}
	run seed_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'remote set-url host /host'* ]]
	[[ "$output" == *'checkout --quiet --no-track -B main refs/remotes/host/main'* ]]
	[[ "$output" == *'Seeded workspace at host-commit.'* ]]
	[[ "$output" != *unexpected-add* ]]
}

@test "fresh seed creates missing remotes" {
	git_ws() {
		case "$*" in
		'remote get-url '*) return 2 ;;
		*) echo "$*" ;;
		esac
	}
	run seed_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'remote add host /host'* ]]
	[[ "$output" == *'remote add origin https://example.invalid/repo.git'* ]]
}

@test "seed without host origin does not create an origin remote" {
	host_git() { return 2; }
	git_ws() { echo "$*"; }
	run seed_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" != *'remote add origin'* ]]
}

@test "detached host checkout selects the exact commit" {
	git_ws() { echo "$*"; }
	run seed_workspace '' host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'checkout --quiet --detach host-commit'* ]]
}

@test "checkout conflict stops recovery without reporting success" {
	git_ws() {
		case "$*" in
		checkout*)
			echo 'checkout conflict'
			return 1
			;;
		*) return 0 ;;
		esac
	}
	run seed_workspace main host-commit
	[ "$status" -ne 0 ]
	[[ "$output" != *'Seeded workspace at'* ]]
}

@test "invalid host checkout fails before touching the workspace" {
	host_git() { return 128; }
	sudo() { echo unexpected-mutation; }
	run main
	[ "$status" -eq 1 ]
	[[ "$output" == *'is not a git checkout'* ]]
	[[ "$output" != *unexpected-mutation* ]]
}

@test "matching workspace keeps its current checkout" {
	git_ws() {
		case "$*" in
		'remote get-url host') return 1 ;;
		'symbolic-ref --quiet --short HEAD') echo main ;;
		'rev-parse HEAD' | 'rev-parse --short HEAD') echo host-commit ;;
		*) echo "$*" ;;
		esac
	}
	run refresh_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'remote add host /host'* ]]
	[[ "$output" == *'Workspace volume matches the host checkout'* ]]
}

@test "clean workspace on the host branch fast forwards" {
	git_ws() {
		case "$*" in
		'symbolic-ref --quiet --short HEAD') echo main ;;
		'rev-parse HEAD') echo old-commit ;;
		'rev-parse --short HEAD') echo host-commit ;;
		*) return 0 ;;
		esac
	}
	run refresh_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'Fast-forwarded workspace volume to the host checkout'* ]]
}

@test "diverged workspace reports both commits without forcing checkout" {
	git_ws() {
		case "$*" in
		'symbolic-ref --quiet --short HEAD') echo main ;;
		'rev-parse HEAD' | 'rev-parse --short HEAD') echo volume-commit ;;
		'rev-parse --short host-commit') echo host-commit ;;
		merge*) return 1 ;;
		*) return 0 ;;
		esac
	}
	run refresh_workspace main host-commit
	[ "$status" -eq 0 ]
	[[ "$output" == *'was not changed'* ]]
	[[ "$output" == *'volume: main volume-commit'* ]]
	[[ "$output" == *'host:   main host-commit'* ]]
}

@test "git wrappers scope commands to their configured checkout" {
	# Reload the real wrappers and replace only the Git executable boundary.
	source "${BATS_TEST_DIRNAME}/../../.devcontainer/local/seed-workspace.sh"
	HOST_DIR=/host
	WORKSPACE_DIR=/workspace
	git() { printf '%s\n' "$*"; }
	run git_ws status --porcelain
	[ "$status" -eq 0 ]
	[[ "$output" == '-c safe.directory=* -C /workspace status --porcelain' ]]
	run host_git rev-parse HEAD
	[ "$status" -eq 0 ]
	[[ "$output" == '-c safe.directory=* -C /host rev-parse HEAD' ]]
}
