# Remediation Inputs — cycle R4 pre-push full-diff review (issue #935)

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-17T02-00
Branch: `bug/hook-test-isolation-737-remainder-935-r4` (no PR yet)
Head reviewed: `e93227f7584e79837334fe3d463fafcf11159993` (local, not pushed; merge-base `cdc7bbc99`) plus the uncommitted P5-T12 check-off in `remediation-plan.2026-10-16T20-56.md`
Review artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-17T02-00.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-17T02-00.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-17T02-00.md`
Prior inputs: `remediation-inputs.2026-10-16T20-56.md`. TEST-1, AC-CHK-1, COV-2, CR-F1..CR-F8, PLAN-1, DOC-3, DOC-4 and EV-3 are fixed; DOC-2 stays with the orchestrator after S9.
Operator ruling for this pass: every finding below, including the non-blocking ones, is fixed before the single push. Insert the fix tasks before P6-T1 of `remediation-plan.2026-10-16T20-56.md` (orchestrator note (5)).

Local context: repository-scope run (report `Pester (10/17/2026 01:37:47)`) 10806 testcases, 0 failures; root line coverage 89.67% (16532/18437). No CI exists for this head.

## Finding AC-CHK-2: acceptance criteria checked against a superseded head

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The checkboxes are in `spec.md`, which is in the cycle write set (`P_SPEC`); unchecking them and writing a note under `evidence/other/` needs no external system, CI result or decision.

- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md` lines 191-195, 197-198, 200-202, 204-207, 209, 213, 217 (AC-1, AC-2, AC-3, AC-4, AC-5, AC-7, AC-8, AC-10, AC-11, AC-12, AC-14, AC-15, AC-16, AC-17, AC-19, AC-23, AC-26).
- Problem: commit `c5e9a77d3` checked these criteria from CI run 38963921545 on the former PR #956 head `048d76cd8`. Cycle R4 (`f96b623ea`, `08130a03e`, `58a355c8a`) changed the Branches, HookReference and Discovery suites and the four EpicStateIsolation helpers that these criteria name, and orchestrator note (1) of the remediation plan states that CI on the follow-on PR head supplies the final-head confirmations. `acceptance-criteria-tracking` rule 4 and `### CI-Dependent Criteria` require the items to stay unchecked until S9, as AC-CHK-1 required for AC-24.
- Fix:
  1. Change `- [x]` to `- [ ]` on the 17 lines above; do not change criterion text. Keep AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22 and AC-25 checked.
  2. Write `evidence/other/r4-ac-recheck-note.<timestamp>.md` with the change, the superseded basis (`c5e9a77d3`, run 38963921545, head `048d76cd8`) and the R4 commits that changed the named files. Do not edit `evidence/qa-gates/s9-ac-verification.2026-10-16T21-46.md`.
  3. Update spec checkbox counts used by remaining tasks (8 checked, 18 unchecked after the fix).
  P7-T10 re-checks the 17 lines at S9.

## Non-blocking related findings (fix in this pass)

### CR-G1: AC-5b no-throw assertion is vacuous after PERF-3

Severity: Medium (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, Describe `discovery guard (both hook surfaces)` BeforeAll lines 113-120; row `AC-5b variable-built hook-load report <Surface>` line 183.
- Problem: `{ $script:VariableLoadLine = @($script:VariableLoadReport[$Surface]) } | Should -Not -Throw` wraps a hashtable read; a throw while building the report fails the BeforeAll and every row of the Describe, and no row asserts the no-throw property.
- Fix: in the BeforeAll add `$script:VariableLoadError = @{}` and make the loop body one line: `try { $script:VariableLoadReport[$surface] = @(foreach ($suite in $DiscoveredSuiteBySurface[$surface]) { Get-EpicStateVariableHookLoadReport -RepoRoot $script:RepoRoot -RelativePath $suite }) } catch { $script:VariableLoadError[$surface] = $_.Exception.Message; $script:VariableLoadReport[$surface] = @() }`. Replace line 183 with `$script:VariableLoadError[$Surface] | Should -BeNullOrEmpty -Because 'building the variable-built hook-load report for the surface must not throw'` and `$script:VariableLoadLine = @($script:VariableLoadReport[$Surface])`. Keep the row name; the F-3 non-vacuity row is unchanged. Net +2 lines.

### CR-G2: `-Seam` path of `Get-EpicStateProbeFinding` skips the error guard

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`, `Get-EpicStateProbeFinding` lines 187-191.
- Problem: with `-Seam` supplied, a missing or unparseable suite gives `$state.Ast = $null`, and `Test-EpicStateProbeCalledFromIt -Ast $null` raises a parameter-binding error instead of a named finding.
- Fix: after line 189 insert `if ($null -ne $state.Error) { return $state.Error }`. Covered by the TEST-3 (c) row.

### CR-G3: parse memo keys are case-insensitive under the new ordinal memos

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` line 46; `Get-EpicStateParsedSource` lines 103-123.
- Problem: `$script:EpicStateParseCache = @{}` compares keys case-insensitively, so texts differing only in case share one AST; the census memo (ordinal, lines 47 and 274) and the closure memo read through it, contradicting the header (lines 31-33). Recorded as an `OBSERVATION:` in `evidence/qa-gates/r4-perf-status.2026-10-17T01-10.md` and left unfixed.
- Fix: replace line 46 with `$script:EpicStateParseCache = [System.Collections.Generic.Dictionary[string, object]]::new([System.StringComparer]::Ordinal)`. Add the Discovery suite row `PERF parse memo keeps texts that differ only in letter case apart`: census of `[pscustomobject]@{ Path = '.claude/hooks/perf-e.ps1'; Text = $script:HookText }`, then of the same path with `$script:HookText.Replace('Get-FixtureCheckpointContent', 'GET-FIXTURECHECKPOINTCONTENT')`; assert `$upper[0].Name | Should -BeExactly 'GET-FIXTURECHECKPOINTCONTENT'`. Record the row failing before the line-46 change under `evidence/regression-testing/`. About +8 lines.

### TEST-2: braced `ExpandableLeaf` alternative has no positive row

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`, `It 'R1 identifies <Case>' -ForEach` table lines 54-115.
- Problem: CR-F4 split the pattern into braced and unbraced alternatives; no fixture in the EpicStateIsolation suites uses `"${...}"`, so the braced alternative is untested.
- Fix: add `expandable braced bound by assignment` (`$HookRoot = '.claude/hooks'`; `BeforeAll { . (Join-Path $script:RepoRoot "${HookRoot}/enforce-x.ps1") }`) and `expandable braced scoped bound by assignment` (`$script:HookRoot = '.claude/hooks'`; `"${script:HookRoot}/enforce-x.ps1"`). About +12 lines.

### TEST-3: memo behaviours without rows

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` Describe `issue #935 PERF memo` (lines 368-458), row `PERF closure memo reads each file once for a repeated closure` (lines 409-425); `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`.
- Problem: no row proves (a) the reader memo identity per root, (b) the library-directory part of the successor key, (c) `Get-EpicStateProbeFinding -Seam`; (d) the "reads each file once" row checks only the second walk.
- Fix: (a) Discovery suite row `PERF reader memo returns one reader per repository root` (two calls with `$script:RepoRoot` are `[object]::ReferenceEquals` true; a call with `'/synthetic-worktrees/other'` is false). (b) Discovery suite row `PERF closure memo keys by library directory`: one `Get-FixtureReader` table mapping `$script:HookFile` to the line `Import-Module 'b.psm1'` and `.claude/lib/fixture/b.psm1` to `function Get-Thing { return 1 }`; with `-LibraryDirectory @()` the closure is `.claude/hooks/a.ps1`, then with the same reader and `-LibraryDirectory @('.claude/lib/fixture')` it is `.claude/hooks/a.ps1,.claude/lib/fixture/b.psm1`. (c) HookReference suite row `PERF probe finding with supplied seams`, using the reader of `AC-6 suite lacking a probe call yields a finding`: `-Seam @('Get-EpicScopeCheckpointText')` gives the same single finding as the call without `-Seam`; `-Seam @()` gives none; a reader without the suite gives `tests/scripts/fixture/Sample.Tests.ps1: suite file not found`. (d) Replace `$readsAfterFirst | Should -BeGreaterThan 0` with `$readsAfterFirst | Should -Be 3 -Because 'the first walk reads .claude/hooks/a.ps1, .codex/hooks/a.ps1 and .claude/lib/fixture/b.psm1 once each'`.
- Line budget: Discovery suite about 487 and HookReference suite about 489 after all fixes; each must stay at or below 500 by D-LC. If either exceeds 500 after formatting, move Describe `issue #935 PERF memo` into a new suite and amend the spec `## Write Set` (AC-21) in the same revision.

### TEST-4: memo-reset row is non-vacuous only in file order

Severity: Low (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, row `PERF memo starts empty when the helper is dot-sourced`, lines 442-457.
- Problem: `$populated` checks only the census and closure-node memos; the reader-memo reset assertion is meaningful only if Describe `discovery guard` ran first.
- Fix: in Arrange add `$null = Get-EpicStateSourceReader -RepoRoot $script:RepoRoot`; extend the `$populated` line with `-and $script:EpicStateReaderCache.Count -gt 0 -and $script:EpicStateParseCache.Count -gt 0`.

### DOC-5: spec does not record the PERF design

Severity: Low (non-blocking)
- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md` line 144 (`#### Performance constraints`); `## Decisions` lines 219-225.
- Problem: line 144 still says only the parse memo is used; no decision records the three new memos (extension of the D6 exception), the BeforeDiscovery data passing, the CR-N4 supersession or the BeforeAll failure semantics.
- Fix: add `- **D7 - PERF (operator direction, 2026-10-16): Discovery suite memos and reused discovery data.**` with those four points and a reference to `evidence/other/r4-perf-cr-n4-supersession.2026-10-17T00-55.md`; amend line 144 to "The Discovery suite uses the `$script:EpicStateParseCache` parse memo and the D7 memos; each file is read, parsed and censused at most once per suite run."

### DOC-6: stale line reference in D6

Severity: Info (non-blocking)
- File and location: `spec.md` line 225 (D6).
- Problem: cites `EpicStateIsolation.Discovery.Helpers.ps1` lines 21-22; the paragraph is at lines 28-29.
- Fix: replace "lines 21-22" with "the `$script:EpicStateParseCache is a deliberate memo exception` paragraph of the header".

### CR-G4: Discovery helper header misstates its loader

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` lines 6-8.
- Problem: says the file is dot-sourced "by the compliance helpers"; the Compliance helper does not dot-source it.
- Fix: "Dot-sourced by enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 and enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1, before EpicStateIsolation.Compliance.Helpers.ps1, whose functions call these."

### CR-G5: memo writers described as pure

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` lines 18, 164, 181, 264.
- Problem: the three new functions write script-scope memos but are described as "Pure"; line 18 lists only the two readers as exceptions.
- Fix: lines 164 and 181 "Deterministic over the injected reader; records the result in $script:EpicStateClosureNodeCache: ..."; line 264 "Deterministic: ... recorded in $script:EpicStateCensusCache ..."; line 18 "Every function is pure over text and AST, apart from the memo writes described below, except the two readers ...".

### CR-G6: inaccurate `-Because` text for the CR-F4 row

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` line 159.
- Problem: "the $Case fixture names no hooks root" is false for `unbalanced brace`, which binds `$HookRoot` to `'.claude/hooks'`.
- Fix: `-Because "the $Case fixture does not form a hook path from a variable bound to a hooks root"`.

### CR-G7: functions edited this cycle remain non-advanced

Severity: Info (non-blocking)
- File and location: `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` `Get-EpicStateSourceReader` (line 72), `Get-EpicStateHookLiteral` (145), `Get-EpicStateLoadedSourceClosure` (215), `Get-EpicStateSeamCensus` (249); `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1` `Get-EpicStateProbeFinding` (176).
- Problem: edited in R4 without `[CmdletBinding()]`, while the new memo functions and the CR-F2 functions have it.
- Fix: add `[CmdletBinding()]` before `[OutputType(...)]` in each; in `Get-EpicStateHookLiteral` replace `return [string[]]$names.ToArray()` with `foreach ($name in $names) { $name }` (callers at lines 233, 320 and 333 iterate or wrap in `@(...)`). Run analyze directly after the edit.

### PLAN-2: plan text for P5-T12, P6-T1 and plan status

Severity: Info (non-blocking)
- File and location: `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/remediation-plan.2026-10-16T20-56.md` line 15, P5-T12 acceptance, P6-T1 acceptance.
- Problem: the P5-T12 check-off is uncommitted and its acceptance (porcelain clean outside `.claude/agent-memory/`) cannot hold once the box is ticked; P6-T1 says P6-T2 commits it, but P6-T3 does; `Status: Draft (planning)` after Phases 0-5 ran.
- Fix: P5-T12 acceptance "... other than `P_SELF` (this task's own check-off)"; P6-T1 "which P6-T3 commits"; line 15 "Status: Executing (Phases 0-5 complete; Phase 6 follows the full-diff review)". Commit with the planner revision.

### EV-4: plan validation pass not recorded

Severity: Info (non-blocking)
- File and location: `evidence/qa-gates/r4-main-plan-validation.2026-10-17T00-49.md` (`VALIDATOR-UNAVAILABLE`); `evidence/qa-gates/r4-findings-status.2026-10-17T01-43.md` PLAN-1 line.
- Problem: PLAN-1 is ledgered `FIXED` without a record of a passing validation.
- Fix: write `evidence/qa-gates/r4-plan-validation.<timestamp>.md` recording `mcp__drm-copilot__validate_orchestration_artifacts` (artifact_type `plan`) `ok: true` for `plan.2026-10-15T17-44.md` and `remediation-plan.2026-10-16T20-56.md` (this review ran both at 2026-10-17T02-00 UTC; the orchestrator also reported a pass); reference it from the next findings ledger.

## Pending items (no finding)

- PC-1: final-head confirmation on the follow-on PR at S9 of the 18 pending criteria, the 13 new rows, the PERF-5 CI time and the direct timing/shuffle runs (orchestrator notes (1), (2), (4), (6), (7)).
- PC-2: `origin/main` moved from `cdc7bbc99` to `b8fcd7790` (PR #959 PoshQC shard and coverage-merge modules; new hook suites such as `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`). P6-T2 merges it, re-runs the Discovery suite and repeats the repository-scope run before the push.
- DOC-2: the follow-on PR description, written by pr-author after S9 (orchestrator).
