# Documentation Check (P2-T6, S15)

Timestamp: 2026-11-19T10-05
Command: sh SCRATCH/issue-1050-docs-tokens.sh (plain `grep -c -F -e <token> <file>` per token and file), run once before the edits and once after
EXIT_CODE: 0
Output Summary: Every token counted 0 in its file before this task and at least 1 after it. Each documented statement is one physical line.

## Per-File Token Counts

| File | Token | Before | After |
| --- | --- | --- | --- |
| `extensions/drm-copilot/README.md` | `## Push-Down CI Workflows` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `ci_workflows` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `payload_version` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `unprotected tag` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `missing tag` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `private source repository` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `#1049` | 0 | 1 |
| `extensions/drm-copilot/README.md` | `Set-CiRequiredChecks.ps1` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `ci_workflows` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `payload_version` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `unprotected tag` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `missing tag` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `private source repository` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `#1049` | 0 | 1 |
| `extensions/drm-copilot/CHANGELOG.md` | `#1050` | 0 | 1 |
| `.github/workflows/README.md` | `## Destination Harness Workflows (Issue #1050)` | 0 | 1 |
| `.github/workflows/README.md` | `harness-python.yml` | 0 | 1 |
| `.github/workflows/README.md` | `harness-powershell.yml` | 0 | 1 |
| `.github/workflows/README.md` | `harness-typescript.yml` | 0 | 1 |
| `.github/workflows/README.md` | `harness-dotnet.yml` | 0 | 1 |

## Content Placement

- `extensions/drm-copilot/README.md`: new section `## Push-Down CI Workflows` after `## Push-Down Pipeline`, stating the `ci_workflows` input and its values, the pin `v<payload_version>`, the bump process (upgrade and re-run; an unedited caller is reported `update`), the two risks, the private-source rule, the #1049 statement, and `Set-CiRequiredChecks.ps1`.
- `extensions/drm-copilot/CHANGELOG.md`: one entry for #1050 at the top of `### Added` under `## [Unreleased]`, carrying the same input, pin, bump process, both risk statements, the private-source rule, and the #1049 statement.
- `.github/workflows/README.md`: new section `## Destination Harness Workflows (Issue #1050)` listing the four `harness-*.yml` files.
