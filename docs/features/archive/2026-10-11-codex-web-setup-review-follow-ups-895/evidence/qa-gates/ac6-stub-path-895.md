# AC-6 check (issue 895)

Timestamp: 2026-10-12T18-05
Command: git grep -n -F -e "local PATH=" -- tests/shell/helpers/codex_web_setup_common.bash; git hash-object tests/fixtures/codex_web_setup/empty-path/.gitkeep
EXIT_CODE: 0
Output Summary: The first command prints one line containing empty-path:
tests/shell/helpers/codex_web_setup_common.bash:26:    local PATH="${FIXTURES}/empty-path"
The second prints e69de29bb2d1d6434b8b29ae775ad8c2e48c5391 (empty file).

## Section: old stub path absent

Command: git grep -c -F -e 'PATH="${BATS_TEST_DIRNAME}"' -- tests/shell/helpers/codex_web_setup_common.bash tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats
Expected exit status of this command alone: 1 (non-zero, no match). Observed: non-zero (an or-echo guard printed its marker).
Output Summary: No output and a non-zero exit status, because git grep -c omits zero-count files and exits 1 when nothing matches. The old tests/shell stub path is gone from all four files.
