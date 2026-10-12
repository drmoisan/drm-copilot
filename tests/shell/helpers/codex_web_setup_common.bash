# ------------------------------------------------------------------------------
# codex_web_setup_common.bash
#
# Purpose:
#   Shared bats helper for the installers, dotnet, and verify suites of
#   .codex/codex-web-setup.sh (test_codex_web_setup_codex_installers.bats,
#   test_codex_web_setup_codex_dotnet.bats, and
#   test_codex_web_setup_codex_verify.bats). Each suite loads this file with the
#   bats load command, so the definitions below exist once.
#
# Layout: this file lives in a subdirectory because the bats runner executes only
# the top-level *.bats files of tests/shell. Each suite keeps its own teardown.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

# Run a command with PATH and HOME limited to the empty fixture directory.
run_with_stub_path() {
    local PATH="${FIXTURES}/empty-path"
    local HOME="${FIXTURES}/empty-path"
    "$@"
}

# Print a replaced command's name and arguments to stderr, which run captures.
record() {
    printf '%s\n' "$*" >&2
}
