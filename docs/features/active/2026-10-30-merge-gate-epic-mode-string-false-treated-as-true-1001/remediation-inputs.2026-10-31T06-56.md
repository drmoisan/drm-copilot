# Remediation Inputs (Issue #1001), feature review 2026-10-31T06-56

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

**Entry timestamp:** 2026-10-31T06-56
**Feature folder:** `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001`
**Base branch:** `main` (merge base `ccec4eba82e272d27f7d81c0e0657a93110de5fb`)
**Head reviewed:** `efa4259525e592dcc42a52a03bb0e938821d774e` on `bug/merge-gate-epic-mode-string-false-1001`
**Work mode:** `full-bug`; AC source is `spec.md` `## Acceptance Criteria` only (14 of 14 evaluated as met)
**Blocking finding count:** 1 (autonomous: 1)
**Audit artifacts:**
- `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/policy-audit.2026-10-31T06-56.md`
- `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/code-review.2026-10-31T06-56.md`
- `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/feature-audit.2026-10-31T06-56.md`

## Findings

### F1 (PA-1) - Repo-wide PowerShell line coverage not established from a full-suite run

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Closing the item needs only a local full-suite Pester run with coverage in this worktree and one evidence file; no source change, external system, policy decision, or CI run is involved.

Policy: `.claude/rules/general-unit-test.md` Coverage Requirements (repo-wide line coverage at or above 85%; root `CLAUDE.md` states no threshold, so the default governs) and the feature-review coverage verification procedure.

Current state: the only PowerShell coverage artifact, `artifacts/pester/powershell-coverage.xml` (report generated 2026-10-31 06:30:44), was produced by `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks`. Its report-level LINE counter is 10717 covered / 11598 missed = 48.03% across the full `config/poshqc-coverage.json` population (22315 lines). The fresh full `tests/scripts` run (`evidence/regression-testing/single-process-tests-scripts.2026-10-31T06-50.md`) ran without coverage, so no repo-wide figure from the full suite is recorded.

Fix:
1. On the current head, run `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts` with coverage enabled (the default PoshQC coverage configuration from `config/poshqc-coverage.json`; do not edit it).
2. Read the report-level LINE counter and the per-file LINE counters of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, and `.claude/hooks/enforce-model-routing-receipt.ps1` from the regenerated `artifacts/pester/powershell-coverage.xml`, and the JUnit totals from `artifacts/pester/pester-junit.xml`.
3. Write `<FEATURE>/evidence/qa-gates/pester-coverage-full.<UTC timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, the JUnit totals, the repo-wide covered/missed/percent, the three per-file figures, and an `Output Summary`. Use repository-relative paths only.
4. Leave `artifacts/pester/powershell-coverage.xml` in place as the full-suite artifact for the re-review.

Verification:
- The run reports 0 failures.
- Repo-wide PowerShell line coverage is at or above 85%. If it is below 85%, record the figure and the per-file list of the largest uncovered files, and report it; do not add coverage exclusions.
- The three hooks remain at 100.00%, 93.55%, and 96.43% (or higher).

## Related non-blocking findings (planner discretion, same files)

These are not counted above.

- CR Minor: the strict `epic_mode` idiom is written inline at each site; a lint or contract check for `[bool]$<name>.epic_mode` and `.epic_mode -eq $true` under `.claude/hooks/` could prevent recurrence. Not required for this item (the spec rejected a shared helper).
- CR Nit: `enforce-model-routing-receipt.EpicModeStrict.Tests.ps1` places `BeforeAll` at file scope while the sibling suites place it inside `Describe`.
- CR Nit: the merge-gate decision rows do not include an integer `1` row; the unit row covers it.

## Do not do

- Do not modify any hook, mirror, or test file to close F1; it is an evidence item.
- Do not modify `config/poshqc-coverage.json`, any policy file under `.claude/rules/` or `.github/instructions/`, or any file under `.codex/`.
- Do not add coverage exclusions, skip tests, or remove tests.
- Write evidence only under `<FEATURE>/evidence/<kind>/`.
