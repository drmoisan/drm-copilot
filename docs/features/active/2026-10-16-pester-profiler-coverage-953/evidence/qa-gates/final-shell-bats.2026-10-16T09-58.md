# Final Bats for CODEX_BATS (issue #953, P6-T9, post-split restart pass)

Timestamp: 2026-10-16T09-58
Command: npx --yes bats tests/shell/test_codex_web_setup_source_safety.bats tests/shell/test_codex_web_setup_pypi_connectivity.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_copy.bats tests/shell/test_codex_web_setup_apt_helpers.bats > SCRATCH/issue-953-final-bats.txt (script SCRATCH/issue-953-p6-t9.sh, run with sh)
EXIT_CODE: 0
Output Summary: bats exit 0. TAP plan line "1..75" (equal to the P0-T25 plan line); 75 "ok" lines; 0 "not ok" lines (the empty set is a subset of the empty P0-T25 set). The wrapper script's own exit status was 1 only because its final `grep` for `not ok` lines matched nothing.

TAP_PLAN: 1..75
OK_COUNT: 75
NOT_OK: none
