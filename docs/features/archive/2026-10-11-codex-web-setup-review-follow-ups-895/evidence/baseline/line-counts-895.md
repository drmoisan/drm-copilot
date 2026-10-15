# File-size baseline (issue 895)

Timestamp: 2026-10-12T17-46
Command: git grep -c -e "" -- .codex/codex-web-setup.sh tests/shell/test_codex_web_setup_codex_copy.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_verify.bats
EXIT_CODE: 0
Output Summary: Five lines, each count below 500:
.codex/codex-web-setup.sh:413
tests/shell/test_codex_web_setup_codex_copy.bats:187
tests/shell/test_codex_web_setup_codex_dotnet.bats:212
tests/shell/test_codex_web_setup_codex_installers.bats:270
tests/shell/test_codex_web_setup_codex_verify.bats:211
