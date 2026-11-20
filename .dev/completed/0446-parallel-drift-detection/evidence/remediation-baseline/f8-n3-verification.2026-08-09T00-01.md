# F8-N3 Verification — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P5-T6]
Finding remediated: **F8-N3** — any `remediation-inputs.*.md` file opened the Layer-1 gate, so a
finding written by an earlier unrelated remediation cycle allowed review of drifted, unsurfaced work.

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`

EXIT_CODE: 1

Supplementary Command (authoritative per-file coverage against the repository's declared 48-file
denominator; the MCP invocation resolves its runsettings from the installed extension bundle and
measures a smaller denominator — see the [P0-T8] artifact's
`## Coverage-Denominator Divergence` section):
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

Supplementary EXIT_CODE: 1 (same single pre-existing failure)

## Output Summary

### The four new narrowing cases pass

All four cases are asserted in
`tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` under the new `Context`
`Layer-1 finding-presence narrowing to the current drift event`. They drive the whole decision path
through `Invoke-ParallelDriftGateDecision` with the **real** `Test-ParallelDriftFindingPresent` and
mock only its two read boundaries, so the narrowing itself is exercised rather than stubbed. The
checkpoint-read seam supplies a latest drift event at `2026-01-02T00-00` against a `declared` radius,
so the item is unresolved and an `allow` can only come from the finding-presence branch. No temporary
file is created.

| Case | Finding file name | Decision |
| --- | --- | --- |
| Stale — timestamp precedes the event's `at` | `remediation-inputs.2026-01-01T00-00.md` | **deny** |
| Equal — timestamp equals the event's `at` | `remediation-inputs.2026-01-02T00-00.md` | **allow** |
| Later — timestamp follows the event's `at` | `remediation-inputs.2026-01-05T00-00.md` | **allow** |
| Non-conforming embedded substring | `remediation-inputs.cycle-one.md` | **deny** |

A fifth assertion checks the deny reason for the stale case still leads with
`PARALLEL_DRIFT_GATE_BLOCKED:` and now names the current-event requirement
(`dated at or after that event`). Two further cases were added to the read-seam `Context`: a
non-canonical `EventAt` reports absence (fail closed), and the pre-existing presence case now passes
an explicit `EventAt`.

Suite results for the two drift-gate suites in isolation: `enforce-parallel-drift-gate.Tests.ps1`
**42 of 42** passing, `enforce-parallel-drift-gate-helpers.Tests.ps1` **26 of 26** passing, including
the 21-row cross-runtime seam test.

The stale case is discriminating rather than vacuous: before this phase the presence check reported
`$true` for the first name matching the `remediation-inputs.` prefix and `.md` suffix regardless of
its timestamp, so `remediation-inputs.2026-01-01T00-00.md` would have opened the gate for an event at
`2026-01-02T00-00`. It now denies.

### PowerShell failed count is unchanged from [P0-T8]

- Pester counts this run: **2099 tests, 2089 passed, 1 failed, 9 skipped**.
- [P0-T8] counts: **2090 tests, 2080 passed, 1 failed, 9 skipped**.
- Failed count: **1 at [P0-T8], 1 now — unchanged.** Delta 0.
- The single failure is the same named pre-existing case and the only `[-]` line in the run output:
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` ::
  `allowed commands / allows gh pr create --body-file artifacts/pr_body_12.md when context exists`.
  That suite reads the real gitignored `artifacts/orchestration/orchestrator-state.json` instead of
  a mocked seam and fails whenever an orchestrated run is live. This cycle may not edit it.
- Passed count rose from 2080 to 2089 (+9) with the tests [P4-T6], [P5-T1], [P5-T2], and [P5-T4]
  added. No previously passing test failed.
- Report-level coverage: LINE **94.99% (3735/3932)**, INSTRUCTION **94.63% (5111/5401)** over 48
  files. No `BRANCH` counter is emitted; the counter types present are exactly `CLASS`,
  `INSTRUCTION`, `LINE`, `METHOD`. No branch figure is invented.

### Per-file LINE coverage of both drift-gate files is at or above 85%

| File | LINE | INSTRUCTION |
| --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | **94.95% (94/99)** | 94.53% (121/128) |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | **100.00% (66/66)** | 100.00% (106/106) |

Both are comfortably above the uniform 85% line-coverage floor. The hook's measured surface grew from
87 to 99 lines with the [P5-T2] and [P5-T3] edits, and all twelve added lines are covered; the five
uncovered lines are still the same dot-source-guarded entrypoint block, which cannot execute while
the suite dot-sources the file. The helpers module grew from 65 to 66 measured lines with [P5-T1]'s
`LatestAt` member, and that line is covered.

Union of the two files: **160/165 = 96.97% LINE**, above the 96.53% single-file benchmark captured
before the Phase 1 split.

## How the Fix Ties the Finding File to the Current Event

Before this phase, `Test-ParallelDriftFindingPresent` reported `$true` for the first directory entry
whose name started with `remediation-inputs.` and ended with `.md`. Any such file — including one
written months earlier by an unrelated remediation cycle for an unrelated finding — satisfied the
Layer-1 allowance, so a drifted item whose current drift had never been surfaced passed the gate.

Three changes tie the allowance to the current event:

1. **[P5-T1] surfaces the timestamp.** `Get-ParallelDriftGateUnresolvedState` in
   `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` now returns a third member `LatestAt`,
   the item-key-to-`at` map it already computed internally through
   `Get-ParallelDriftGateLatestEventMap`. The map is passed through unchanged, so the decision path
   reads the current unresolved event's timestamp without a second derivation that could disagree
   with the first. `LatestAt` is an empty map whenever `Malformed` is `$true`, because an unreadable
   log carries no trustworthy timestamp.
2. **[P5-T2] narrows the presence check.** `Test-ParallelDriftFindingPresent` takes a new mandatory
   `EventAt` parameter. For each candidate entry it still applies the ordinal prefix and suffix
   tests, then takes the `yyyy-MM-ddTHH-mm` substring with `Substring` at the fixed offset
   `$script:FindingFilePrefix.Length` for `$script:FindingFileStampLength` (16) characters, requires
   that substring to satisfy the canonical pattern through the Phase 4 predicate
   `Test-ParallelDriftGateCanonicalTimestamp`, and reports `$true` only when
   `[string]::CompareOrdinal($stamp, $EventAt) -ge 0`. A name too short to carry the substring, or
   whose substring is non-conforming, is skipped rather than accepted. A non-canonical `EventAt`
   reports `$false` outright, so an ordinal comparison across shapes — the F8-N4 inversion — cannot
   occur here either.
3. **[P5-T3] binds the call site.** `Invoke-ParallelDriftGateDecision` reads
   `$driftState.LatestAt[$itemKey]` for the resolved item and passes it as `-EventAt`. When no latest
   `at` is available for that item — which is exactly the malformed-log case, since `LatestAt` is
   emptied then — no allowance is attempted at all and the gate denies fail-closed rather than
   falling back to bare presence. The deny reason still leads with `PARALLEL_DRIFT_GATE_BLOCKED:`.

The allowance therefore requires a finding recorded for the current event or later, which is exactly
what the parallel-orchestrator writes when it surfaces the current drift. Reuse of an earlier cycle's
finding is no longer possible.

## Presence-Gating Constraint Verified by Grep

Both files were searched for the prohibited mechanisms at the end of the phase. Patterns searched:
`\bgit\b`, `Invoke-GitExe`, `-like`, `-Filter`, `-Include`, `WildcardPattern`, `Compare-Object`,
`Get-Content`, `[Dd]iff`.

- `.claude/hooks/enforce-parallel-drift-gate.ps1` — five matches, four of them in comment-based help
  or inline comments that describe the prohibition. The single executable match is line 94,
  `Get-Content -LiteralPath $script:ParallelCheckpointPath -Raw`, which is the documented
  checkpoint-read seam reading the JSON checkpoint. It is not a read of any finding file's content.
- `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` — six matches, all in comment-based help or
  inline comments.

Result: **no git invocation, no path-glob matching (`-like`, `-Filter`, `-Include`, or
`WildcardPattern` appear nowhere in executable code), no diff computation, and no finding-file
content read** in the hook or its helpers. The narrowing inspects directory entry NAMES only.
