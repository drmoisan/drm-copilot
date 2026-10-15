# Scope lock (issue 895)

Timestamp: 2026-10-12T17-50

The Phase 1 change set outside the feature folder is locked to exactly these nine repository paths:

- `.codex/codex-web-setup.sh`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh`
- `tests/shell/helpers/codex_web_setup_common.bash`
- `tests/shell/test_codex_web_setup_codex_installers.bats`
- `tests/shell/test_codex_web_setup_codex_dotnet.bats`
- `tests/shell/test_codex_web_setup_codex_verify.bats`
- `tests/shell/test_codex_web_setup_codex_copy.bats`
- `tests/fixtures/codex_web_setup/solution-root/Alpha.sln`
- `tests/fixtures/codex_web_setup/empty-path/.gitkeep`

Implementation completion is defined by P1-T18.
