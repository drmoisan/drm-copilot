# Final scope boundary (issue 895)

Timestamp: 2026-10-12T18-07
Command: git diff --name-only origin/main...HEAD -- .codex tests extensions; git status --porcelain -- .codex tests extensions
EXIT_CODE: 0
Output Summary: origin/main was present locally (88946d10a47911a426abec906b2b2163814f5950), so no fetch was needed. The diff lists exactly the nine paths of the scope lock and the porcelain output is empty.

git diff --name-only output:
.codex/codex-web-setup.sh
extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh
tests/fixtures/codex_web_setup/empty-path/.gitkeep
tests/fixtures/codex_web_setup/solution-root/Alpha.sln
tests/shell/helpers/codex_web_setup_common.bash
tests/shell/test_codex_web_setup_codex_copy.bats
tests/shell/test_codex_web_setup_codex_dotnet.bats
tests/shell/test_codex_web_setup_codex_installers.bats
tests/shell/test_codex_web_setup_codex_verify.bats

git status --porcelain output: empty.
