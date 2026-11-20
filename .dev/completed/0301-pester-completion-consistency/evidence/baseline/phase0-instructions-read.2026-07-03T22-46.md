# Phase 0 — Policy Read Evidence

Timestamp: 2026-07-04T09-30

## Policy Order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`

## Files Read

- `CLAUDE.md` (repo root) — confirmed tone policy (strictly professional, factual, neutral) and the policy-compliance reading order apply to this change.
- `.claude/rules/general-code-change.md` — confirmed cross-language code-change policy applies to `enforce-completion-consistency.ps1` and `enforce-completion-helpers.ps1`: simplicity-first design, 500-line file limit, fail-fast/explicit error handling, and the mandatory seven-stage toolchain loop (restart from formatting on any file change or failure).
- `.claude/rules/general-unit-test.md` — confirmed the test-file-location rule (tests live under `tests/` mirroring production structure, e.g. `tests/scripts/claude-hooks/`) and the >=85% line / >=75% branch coverage requirement apply to the Pester tests in scope (`enforce-completion-consistency.Tests.ps1`, `enforce-completion-consistency-codex.Tests.ps1`).
- `.claude/rules/powershell.md` — confirmed the mandatory PoshQC toolchain order: format (`mcp__drm-copilot__run_poshqc_format`) -> analyze (`mcp__drm-copilot__run_poshqc_analyze`) -> test (`mcp__drm-copilot__run_poshqc_test`), with no type-check stage for PowerShell, and the change budget / design-seam / mocking rules applicable to hook scripts.

## Acceptance Criteria Section Confirmation

Confirmed `docs/features/active/2026-07-03-pester-completion-consistency-301/issue.md` contains an explicit `## Acceptance Criteria` heading at line 20. This section is the sole minor-audit acceptance-criteria source, per `docs/features/active/2026-07-03-pester-completion-consistency-301/issue.md` line 10 (`Work Mode: minor-audit`).
