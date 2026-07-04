# Baseline vs Final Coverage Comparison — Remediation Cycle 2

Timestamp: 2026-07-04T13-15

## P2-T4: `<sourcefile>` Entry Count and No-Regression Check

Command: `grep -n "<sourcefile" artifacts/pester/powershell-coverage.xml | wc -l`
Result: **19** (not the 20 anticipated by the plan task text).

### Count Reconciliation (documented discrepancy)

The repo-root `CodeCoverage.Path` array lists 16 entries pre-cycle-1-fix plus the 4 in-scope hook files added in cycle 1 = 20 listed `Path` array entries. However, `.claude/hooks/enforce-pr-author-skill.ps1` is listed **twice** in the `Path` array (once in the issue #272 comment block, once again in the issue #275 comment block) — this is a pre-existing duplication that predates both remediation cycles. Pester's coverage engine resolves the `Path` array to unique file paths before instrumenting, so the duplicate collapses to a single `<sourcefile>` entry. This yields 15 unique pre-existing entries + 4 new in-scope entries = **19** unique `<sourcefile>` entries, which is what the regenerated `artifacts/pester/powershell-coverage.xml` shows. This was independently verified by re-running the same command twice (see `evidence/qa-gates/final-powershell-pester.2026-07-04T13-15.md`); both runs produced 19.

`grep -n "<sourcefile" artifacts/pester/powershell-coverage.xml`:

```
509:    <sourcefile name="check-powershell-test-purity.ps1">
570:    <sourcefile name="check-python-test-purity.ps1">
636:    <sourcefile name="enforce-completion-consistency.ps1">      (.claude/hooks)
765:    <sourcefile name="enforce-completion-helpers.ps1">           (.claude/hooks)
814:    <sourcefile name="enforce-epic-merge-gate.ps1">
896:    <sourcefile name="enforce-epic-wave-barrier.ps1">
989:    <sourcefile name="enforce-epic-worktree-removal-gate.ps1">
1056:    <sourcefile name="enforce-powershell-batch-budget.ps1">
1143:    <sourcefile name="enforce-pr-author-skill.epic-base-branch.ps1">
1172:    <sourcefile name="enforce-pr-author-skill.ps1">
1293:    <sourcefile name="enforce-python-batch-budget.ps1">
1380:    <sourcefile name="validate-bash.ps1">
1424:    <sourcefile name="validate-orchestrator-output.ps1">
1605:    <sourcefile name="enforce-completion-consistency.ps1">      (.codex/hooks)
1734:    <sourcefile name="enforce-completion-helpers.ps1">           (.codex/hooks)
1922:    <sourcefile name="Invoke-FullRelease.ps1">
2006:    <sourcefile name="Invoke-MarketplacePublish.ps1">
2074:    <sourcefile name="Invoke-ReleaseTagPush.ps1">
2175:    <sourcefile name="Publish-DrmCopilotExtension.ps1">
```

None of the 15 pre-existing unique entries were dropped or renamed. No entry disappeared between the cycle-1 final state and this cycle's regenerated report.

### No-Regression Check — `.claude/hooks/*` (Cycle-1 Figures)

Command: `awk '/<sourcefile name=/ {name=$0} /counter type="LINE"/ {print name" -> "$0}' artifacts/pester/powershell-coverage.xml`

| File | Cycle-1 final (2026-07-04T12-00) | Cycle-2 final (this run) | Regression? |
|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 91.87% (113/123) | 91.87% (113/123) | No |
| `.claude/hooks/enforce-completion-helpers.ps1` | 93.02% (40/43) | 93.02% (40/43) | No |

No regression on either `.claude/hooks/*` file. The 15 pre-existing entries (unrelated to the completion-consistency hook set) report `covered="0"` in this narrowly-scoped run, identical to their cycle-1 state, because this run scopes `-ScanFolders` to only the two completion-consistency test files; none of the 15 pre-existing files are exercised by those two test files, so their coverage is unchanged (not regressed), consistent with cycle 1's own no-regression methodology.

## P2-T5: Before/After Comparison (All Four In-Scope Files)

| File | Cycle-2 baseline (pre-fix, this cycle, 2026-07-04T13-15) | Cycle-2 final (post-fix, this cycle, 2026-07-04T13-15) | Meets >= 85% floor? |
|---|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 91.87% (113/123) | 91.87% (113/123) | Yes |
| `.claude/hooks/enforce-completion-helpers.ps1` | 93.02% (40/43) | 93.02% (40/43) | Yes |
| `.codex/hooks/enforce-completion-consistency.ps1` | 0.00% (0/123) | 52.85% (65/123) | **No** |
| `.codex/hooks/enforce-completion-helpers.ps1` | 0.00% (0/43) | 76.74% (33/43) | **No** |

Sources: baseline figures from `evidence/remediation-baseline/baseline-powershell-pester.2026-07-04T13-15.md`; final figures from `evidence/qa-gates/final-powershell-pester.2026-07-04T13-15.md`.

## Overall Finding (Honest Status — Not a PASS)

The Phase 1 fix (retarget `$script:UnderTest` + 2 byte-identity assertions) closes the coverage-**measurement** gap for all four in-scope files: all four now appear as `<sourcefile>` entries with real, non-zero, individually-attributed coverage (previously the two `.codex/hooks/*` files showed 0.00% because no test dot-sourced their canonical path). This is a genuine improvement over the pre-fix state.

However, the fix does **not** close the coverage-**floor** gap for two of the four files. `.codex/hooks/enforce-completion-consistency.ps1` (52.85%) and `.codex/hooks/enforce-completion-helpers.ps1` (76.74%) remain below the 85% line-coverage floor required by `.claude/rules/general-unit-test.md` and `.claude/rules/powershell.md`. Root cause: the `enforce-completion-consistency-codex.Tests.ps1` file has only 2 behavioral `It` blocks (unchanged in count by this cycle — the 2 new `It` blocks added in Phase 1 are non-behavioral byte-identity assertions using `Get-FileHash`, which do not invoke `Invoke-CompletionConsistencyDecision` or exercise any additional code path), versus 49 behavioral `It` blocks for the `.claude/hooks` counterpart. Uncovered functions in the Codex hook include `Get-CheckpointFileContent` (0/3), `Resolve-EditedCheckpointContent` (0/15), and partially-covered `Test-CompletionAsserted` (4/14) and `Get-MissingCompletionEvidence` (27/40).

**Per this plan's Do-Not-Do list ("Do not mark AC 3 or the overall feature PASS without a coverage artifact that shows all four in-scope files (not two) at or above the coverage floor"), this remediation cycle does NOT satisfy the condition required to mark AC 3 PASS.** This finding is recorded here for feature-review's independent reaudit and is not resolved by any task in this cycle's declared scope (the cycle's four named fix items were: (1) retarget the Codex test's dot-source target, (2) rerun coverage and record a corrected comparison, (3) hand off AC 3 re-evaluation, (4) optionally correct the reversed rationale sentence — none of the four named items authorize adding new behavioral test scenarios to the Codex hook set).

Output Summary: Coverage-measurement gap closed for all four in-scope files (all now report real, non-zero coverage); no regression on the two `.claude/hooks/*` files (91.87%/93.02%, unchanged) or any of the 15 pre-existing `CodeCoverage.Path` entries. Coverage-floor gap remains open for two of the four files (`.codex/hooks/enforce-completion-consistency.ps1` = 52.85%, `.codex/hooks/enforce-completion-helpers.ps1` = 76.74%, both below the 85% floor). `<sourcefile>` entry count is 19 (not 20), reconciled above as a pre-existing `enforce-pr-author-skill.ps1` Path-array duplicate collapsing to one unique entry — no entries were dropped or renamed.
