# Phase 1 scope boundary (issue 895)

Timestamp: 2026-10-12T18-00
Command: git diff --name-only HEAD -- .codex tests extensions; git status --porcelain -- .codex tests extensions
EXIT_CODE: 0
Output Summary: The diff lists exactly the nine paths of the scope lock and no other path. The porcelain output shows only M and A entries for those nine paths.

git diff --name-only HEAD output:
.codex/codex-web-setup.sh
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
tests/fixtures/codex_web_setup/empty-path/.gitkeep
tests/fixtures/codex_web_setup/solution-root/Alpha.sln
tests/shell/helpers/codex_web_setup_common.bash
tests/shell/test_codex_web_setup_codex_copy.bats
tests/shell/test_codex_web_setup_codex_dotnet.bats
tests/shell/test_codex_web_setup_codex_installers.bats
tests/shell/test_codex_web_setup_codex_verify.bats

git status --porcelain output:
M  .codex/codex-web-setup.sh
M  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
A  tests/fixtures/codex_web_setup/empty-path/.gitkeep
A  tests/fixtures/codex_web_setup/solution-root/Alpha.sln
A  tests/shell/helpers/codex_web_setup_common.bash
M  tests/shell/test_codex_web_setup_codex_copy.bats
M  tests/shell/test_codex_web_setup_codex_dotnet.bats
M  tests/shell/test_codex_web_setup_codex_installers.bats
M  tests/shell/test_codex_web_setup_codex_verify.bats
