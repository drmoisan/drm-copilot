# Final QC: Shell Bats (P8-T16 / P6-T9, sharding path)

Timestamp: 2026-10-16T13-57
Command: sh "SCRATCH/issue-953-p8-t16-p6-t9.sh" — `npx --yes bats tests/shell/test_codex_web_setup_source_safety.bats tests/shell/test_codex_web_setup_pypi_connectivity.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_copy.bats tests/shell/test_codex_web_setup_apt_helpers.bats > SCRATCH/issue-953-final-bats.txt`
EXIT_CODE: 0

Output Summary:
- bats exit code 0 (the wrapper script's own exit status was 1 because its final `grep` for `not ok` lines matched nothing).
- TAP plan line: `1..75`, equal to the P0-T25 plan line.
- ok lines: 75; not ok lines: 0 (NOT_OK: none), a subset of the empty baseline set.
- Result: PASS.
