# Baseline vs Final Coverage Comparison (Remediation Cycle 1)

Timestamp: 2026-07-04T12-00

## Baseline (Pre-Fix)

Source: `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/remediation-baseline/baseline-powershell-pester.2026-07-04T12-00.md`

- `grep -n "sourcefile" artifacts/pester/powershell-coverage.xml` -> no matches for any of the four in-scope files. Coverage-measurement gap confirmed: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1` were entirely absent from `CodeCoverage.Path` and therefore absent from the report.
- 51/51 tests passing (same test files as final run).

## Final (Post-Fix)

Source: `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/final-powershell-pester.2026-07-04T12-00.md`

- 51/51 tests passing, 0 failures, 0 errors.
- All four in-scope files now appear as `<sourcefile>` entries (measurement gap closed):

| File | LINE missed | LINE covered | Line % |
|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 10 | 113 | 91.87% |
| `.claude/hooks/enforce-completion-helpers.ps1` | 3 | 40 | 93.02% |
| `.codex/hooks/enforce-completion-consistency.ps1` | 123 | 0 | 0.00% |
| `.codex/hooks/enforce-completion-helpers.ps1` | 43 | 0 | 0.00% |

- `<counter type="BRANCH">` does not exist anywhere in the report (pre-existing Pester tooling limitation; not introduced by this cycle).

## No-Regression Check on the 16 Pre-Existing Entries

Command: `awk '/<sourcefile name=/ {name=$0} /counter type="LINE"/ {print name" -> "$0}' artifacts/pester/powershell-coverage.xml`

All 16 pre-existing `CodeCoverage.Path` entries (`validate-bash.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-pr-author-skill.ps1` (both occurrences), `Publish-DrmCopilotExtension.ps1`, `Invoke-FullRelease.ps1`, `Invoke-MarketplacePublish.ps1`, `Invoke-ReleaseTagPush.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `validate-orchestrator-output.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`) report `covered="0"` at the class level, identical to their pre-fix state, because the scan is scoped to only the two completion-consistency test files in both the baseline and final runs, and none of the 16 pre-existing files are exercised by those two test files. No pre-existing entry's coverage decreased: all remain at their pre-existing 0% (unchanged) under this narrow test-file scope. No regression is present.

## Gap Identified (Not Resolved by This Remediation Cycle)

Two of the four in-scope files (`.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`) show 0.00% real line coverage. Root cause (see `final-powershell-pester.2026-07-04T12-00.md` for full detail): the existing `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` dot-sources the bundled-extension mirror path (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`), not the canonical repo-root `.codex/hooks/` path added to `CodeCoverage.Path` in this cycle. No test file anywhere in the repository exercises the canonical `.codex/hooks/enforce-completion-consistency.ps1` or `.codex/hooks/enforce-completion-helpers.ps1` paths directly. This is a pre-existing test-authoring gap distinct from the `CodeCoverage.Path` configuration gap this cycle was scoped to close, and modifying the Codex test file's dot-source target is outside this cycle's declared scope (four named hook files + `pester.runsettings.psd1` + `tsconfig.json` only).

Output Summary: Coverage-measurement gap for all four in-scope files is closed (all four now appear as `<sourcefile>` entries). No regression on any of the 16 pre-existing entries. Two of the four files (`.claude/hooks/*`) achieve real line coverage above the 85% floor (91.87%, 93.02%); the other two (`.codex/hooks/*`) show 0.00% real coverage due to a pre-existing test-authoring gap (Codex test exercises the bundled mirror path, not the canonical path) that is outside this cycle's declared scope. `BRANCH` coverage cannot be evaluated for any file because Pester's coverage export does not emit a `BRANCH` counter.
