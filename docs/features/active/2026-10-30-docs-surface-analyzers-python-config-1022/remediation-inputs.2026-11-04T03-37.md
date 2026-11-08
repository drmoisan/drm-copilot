# Remediation Inputs - issue #1022 (review 2026-11-04T03-37)

Review-Verdict: AWAITING_CI
Remediation-Mode: none (no autonomous finding)

Source review artifacts (this folder):

- `policy-audit.2026-11-04T03-37.md`
- `code-review.2026-11-04T03-37.md`
- `feature-audit.2026-11-04T03-37.md`

Branch: `feature/docs-surface-analyzers-python-config-1022-r2`, head `fc4f2e8d4`. Base: `origin/epic/documentation-estate-tooling-integration` (merge base `06012704f`).

## Blocking Findings

### F1 - CI-dependent acceptance criteria S22 and U14 unchecked

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: Awaited workflow `.github/workflows/ci.yml`, check `poshqc / PowerShell QC` (Pester shard jobs on windows-latest, with coverage) for the PR head; no pull request exists yet for head `fc4f2e8d4`. The local JaCoCo file reproduces the recorded per-file figures (99.22% to 100% for the eighteen new modules), and the reviewer docs-folder Pester run reports 1315 of 1315; only the CI report on the PR head can satisfy the two criteria as written.
- File: `.claude/lib/docs/` (the eighteen new modules); criteria `spec.md` line 1057 (S22) and `user-story.md` line 101 (U14)
- Symbol: not applicable (coverage criterion over the new modules)
- Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md` `### CI-Dependent Criteria`; `.claude/rules/general-unit-test.md` coverage requirements.
- Evidence: `artifacts/pester/powershell-coverage.xml` parsed by the reviewer (root LINE 24348 of 26088, 93.33%); `evidence/qa-gates/qa-pester-coverage.2026-11-04T03-04.md`; `evidence/qa-gates/coverage-delta.2026-11-04T03-04.md`; `evidence/qa-gates/ac-status.2026-11-04T03-26.md`.
- Required change: none in a remediation cycle. Open the PR into the epic integration branch (dispatch `ci.yml` manually if no checks start, since it triggers only on PRs into `main` or `development`). The item's own orchestrator run checks off S22 and U14 at S9 after a green conclusion with per-file figures at or above 85%, then re-runs the CI gate on the new head.

## Non-blocking Items

- No file-size Warning applies (largest covered file 467 logical lines).
- Info: case-insensitive comparisons on punctuation, integers and internal constants in several new modules (no behavioral effect); see the code review.
- Info: `Invoke-DocsInventoryCommand` reads each file in full before the per-input bound, as the spec's flow defines.
- Info: `Select-DocsInventoryRow` parameter `$Profile` shadows the automatic variable inside the function.
- Info: the self-review attributes `Invoke-DocsContextMember` to 1020; it is a private helper in 1022's `DocsInventory.psm1`.
- Info: `Invoke-DocsInventoryCommand` declares no `SupportsShouldProcess`; the write primitive in the 1020 entry script does.

## Artifact Paths

- policy-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/policy-audit.2026-11-04T03-37.md
- code-review-path: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/code-review.2026-11-04T03-37.md
- feature-audit-path: docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/feature-audit.2026-11-04T03-37.md
