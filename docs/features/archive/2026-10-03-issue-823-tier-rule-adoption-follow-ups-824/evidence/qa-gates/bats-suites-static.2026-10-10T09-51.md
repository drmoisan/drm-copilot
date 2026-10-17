# P15-T7 Static Checks of BATS-NEW and the Seven New Fixtures

Timestamp: 2026-10-10T09-51
Command: grep -c -E "BATS_TEST_TMPDIR|BATS_TMPDIR|BATS_FILE_TMPDIR|BATS_RUN_TMPDIR" tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats; reader R6 of Appendix P; git check-ignore -v tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats tests/fixtures/codex_web_setup/dotnet-repo/global.json tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json tests/fixtures/codex_web_setup/dotnet-repo/coverage.config tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt tests/fixtures/codex_web_setup/bashrc-with-ci.txt; git status --porcelain --untracked-files=all -- tests/shell tests/fixtures/codex_web_setup
EXIT_CODE: 0
Output Summary:
- grep temp-directory variables: exit 1 (no match in any file); printed:
  - tests/shell/test_codex_web_setup_codex_installers.bats:0
  - tests/shell/test_codex_web_setup_codex_dotnet.bats:0
  - tests/shell/test_codex_web_setup_codex_verify.bats:0
- R6: exit 0; printed `CHECKED 10 CR_FILES 0 []`.
- git check-ignore -v: exit 1; no output (no path is ignored).
- git status --porcelain: exit 0; printed exactly ten `??` lines:
  - ?? tests/fixtures/codex_web_setup/bashrc-with-ci.txt
  - ?? tests/fixtures/codex_web_setup/dotnet-repo/coverage.config
  - ?? tests/fixtures/codex_web_setup/dotnet-repo/dotnet-tools.json
  - ?? tests/fixtures/codex_web_setup/dotnet-repo/global.json
  - ?? tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/dotnet/placeholder.txt
  - ?? tests/fixtures/codex_web_setup/dotnet-sdk-installed/.dotnet-sdk/sdk/8.0.100/placeholder.txt
  - ?? tests/fixtures/codex_web_setup/dotnet-sdk-installed/global.json
  - ?? tests/shell/test_codex_web_setup_codex_dotnet.bats
  - ?? tests/shell/test_codex_web_setup_codex_installers.bats
  - ?? tests/shell/test_codex_web_setup_codex_verify.bats
