# CI-Dependent Criteria (issue #1009)

Timestamp: 2026-10-30T19-04
Status: pending-CI
Owner: orchestrator S9
Command: none in this task; the pull request does not exist during execution, so no CI result is read here
EXIT_CODE: 0
Output Summary: AC-13, AC-25, and AC-39 stay unchecked in `spec.md` `## Acceptance Criteria`. Per `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`, the item's orchestrator run confirms the checks on the pull-request head at S9 and owns the check-off.

CI clauses:
- AC-13: the twin suite `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` passing on the Linux hook-suite job.
- AC-25: `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` passing in CI (Linux hook-suite job and Windows shards).
- AC-39: the toolchain and isolation suites passing in CI.

Jobs to confirm as `success` on the pull-request head for a full run:
- `CI full run`
- `poshqc / PowerShell QC`
- `poshqc / PowerShell hook suites (Linux)`

Required contexts (from the brief's `## CI Shape and Required Checks`), each to be `success`:
1. `drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest)`
2. `drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest)`
3. `docs-validation / Documentation Validation`
4. `poshqc / PowerShell QC`
5. `shell-coverage / Shell Coverage (Bats + kcov)`
6. `security-scan / Security Scanning`
7. `quality-checks7 / Code Quality & Tests (3.10)`
8. `quality-checks7 / Code Quality & Tests (3.11)`
9. `quality-checks7 / Code Quality & Tests (3.12)`
10. `quality-checks7 / Code Quality & Tests (3.13)`
11. `build-check / Build Package`

Local evidence for these clauses (not a substitute for CI): `twin-suite.2026-10-30T17-30.md`, `pester-touched.2026-10-30T18-27.md`, `pester-full.2026-10-30T18-43.md`, `isolation-shuffle.2026-10-30T18-48.md`, `isolation-single-process.2026-10-30T19-04.md`.
