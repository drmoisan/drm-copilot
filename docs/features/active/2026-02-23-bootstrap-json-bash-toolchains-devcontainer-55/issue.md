# bootstrap-json-bash-toolchains-devcontainer (Issue #55)

- Date captured: 2026-02-23
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-json-bash-toolchains-devcontainer/ (Issue #55)

- Issue: #55
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/55
- Last Updated: 2026-02-23
- Work Mode: minor-audit

## Problem / Why

The repo already has partial JSON and Bash quality tooling (`scripts.dev_tools.format_json`, `scripts.dev_tools.validate_json`, `scripts.dev_tools.shell_qc`) and VS Code tasks that reference Bash host bootstrap/verify entry points. However, key platform pieces are missing or incomplete: there is no committed `.devcontainer` configuration, and task-referenced Bash bootstrap scripts (`scripts/bash/bootstrap-host.sh`, `scripts/bash/verify-host.sh`) are not present.

This creates onboarding friction and inconsistent quality execution across Windows, Linux/macOS, local Docker, and GitHub Codespaces. We need a deterministic bootstrap path so JSON and Bash format → lint → type-check (where applicable) → test loops are runnable in both local and cloud dev environments.

## Proposed Behavior

Bootstrap a complete, documented developer workflow for JSON and Bash quality checks and environment setup:

- Provide an operational `.devcontainer` baseline that works for local Docker and Codespaces.
- Ensure required CLI dependencies for JSON/Bash toolchains are provisioned in that environment (for example `jq`, `shfmt`, `shellcheck`, `bats`, and `kcov` where coverage is expected).
- Implement or wire the missing Bash host scripts referenced by tasks (`scripts/bash/bootstrap-host.sh` and `scripts/bash/verify-host.sh`) so Linux/macOS paths are real and deterministic.
- Keep existing Python/PowerShell/TypeScript workflows intact while adding JSON/Bash bootstrap parity.
- Make setup and verification discoverable via repo docs and task labels already present in `.vscode/tasks.json`.

## Acceptance Criteria (early draft)

- [ ] A committed `.devcontainer` configuration exists and can be opened successfully in both local Docker and Codespaces.
- [ ] Running the JSON toolchain in the provisioned environment succeeds: format (`scripts.dev_tools.format_json`) and validate (`scripts.dev_tools.validate_json`).
- [ ] Running the Bash toolchain in the provisioned environment succeeds: format/lint/tests via `scripts.dev_tools.shell_qc` (including graceful skip behavior when no shell files/tests are present).
- [ ] VS Code tasks `Dev: Host Bootstrap (Bash)` and `Dev: Host Verify (Bash)` execute against real `scripts/bash/*.sh` entry points (no missing-file failures).
- [ ] Missing-tool behavior remains explicit and actionable (clear install hints instead of silent failures).
- [ ] Existing non-Bash toolchains remain non-regressed (Python and PowerShell task flow still functional).

## Constraints & Risks

- `.vscode` and `.devcontainer` JSON files may be JSONC and must remain compatible with existing JSON governance rules (`json_config.py` currently excludes `.devcontainer` from jq formatting).
- Local Docker and Codespaces differ in filesystem/performance/network characteristics; bootstrap steps must avoid assumptions that only work in one environment.
- Dependency risk: tool versions for `jq`/`shfmt`/`shellcheck`/`bats`/`kcov` may vary by base image and can cause inconsistent lint/test behavior.
- Scope risk: this effort should bootstrap environment/toolchain wiring, not redesign existing quality scripts.
- Backward-compat risk: task labels/commands are already referenced by contributors and should remain stable unless migration notes are provided.

## Test Conditions to Consider

- [ ] Unit coverage areas: path resolution and failure messaging in Bash bootstrap/verify scripts; JSON/Bash tool detection and skip behavior.
- [ ] Integration scenarios: fresh local Docker devcontainer startup, fresh Codespaces startup, and rerun after cache/tool install changes.
- [ ] Integration scenarios: execute task chain for JSON and Bash checks from `.vscode/tasks.json` end-to-end.
- [ ] CLI/API examples: run `poetry run python -m scripts.dev_tools.format_json`, `poetry run python -m scripts.dev_tools.validate_json`, and `poetry run python -m scripts.dev_tools.shell_qc check|format|test`.
- [ ] Edge cases: repo with no discoverable shell scripts/tests, missing optional coverage tools, and partial tool availability with deterministic error output.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/bootstrap-json-bash-toolchains-devcontainer/` folder from the template