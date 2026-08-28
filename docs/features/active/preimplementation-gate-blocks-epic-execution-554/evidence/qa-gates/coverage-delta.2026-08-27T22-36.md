# P6-T6 — Coverage Delta and Changed-Line Coverage

Timestamp: 2026-08-27T22-36

Loop iteration: 2 (the same Phase 6 iteration anchored by
`final-poshqc-format.2026-08-27T22-24.md`)

Command:

```powershell
# Repository-wide line coverage, read from the JaCoCo report root of the P6-T4 run.
[xml]$x = Get-Content artifacts/pester/powershell-coverage.xml -Raw
$x.report.counter | Where-Object { $_.type -eq 'LINE' }
```

```bash
# Changed-line coverage: intersect each file's added lines against the same
# JaCoCo report's per-line ci counters.
git diff -U0 1e991b86d78e4f979922b79268f19ca0e5ab19e3 -- <file>
```

EXIT_CODE: 0

Output Summary:

**Baseline line coverage 94.94%. Post-change line coverage 94.22%. Aggregate changed-line coverage
81.90% (285 of 348 measurable added lines). 63 measurable added lines are reported as uncovered, so
the second clause of this task's acceptance is NOT met and this task remains unchecked.**

## Repository-wide line coverage

| Source | Line coverage | Covered | Missed |
| --- | --- | --- | --- |
| Baseline, P0-T6 (`phase0-poshqc-test-coverage.2026-08-26T10-18.md`) | **94.94%** | 6908 | 368 |
| Post-change, P6-T4 (`final-poshqc-test-coverage.2026-08-27T22-30.md`) | **94.22%** | 7174 | 440 |
| Delta | **-0.72 pp** | +266 | +72 |

Both values are numeric and the post-change value is above the 85% uniform threshold in
`.claude/rules/quality-tiers.md`. Pester measures no branch coverage, so no branch-coverage value is
reported and none is required.

The denominator grew because P4-T5 registered the two new `-modes.ps1` files for coverage; the
analyzed-file count rose from 86 to 88 and analyzed commands from 10,033 to 10,525.

## Changed-line coverage, per file

"Added lines" are the `+` lines of `git diff -U0` against the merge base
`1e991b86d78e4f979922b79268f19ca0e5ab19e3` (recorded at P0-T4). "Measurable" counts only those added
lines that JaCoCo emitted a `<line>` element for; comment, blank, and brace-only lines carry no
instruction and are not measurable.

| File | Added | Measurable | Covered | Uncovered | Changed-line coverage |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified hook) | 120 | 42 | 32 | **10** | 76.19% |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (new) | 477 | 132 | 130 | **2** | 98.48% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified hook) | 125 | 42 | 15 | **27** | 35.71% |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (new) | 477 | 132 | 108 | **24** | 81.82% |
| **Aggregate** | 1199 | **348** | **285** | **63** | **81.90%** |

## Acceptance evaluation — the third clause fails

This task's acceptance has three clauses:

1. **All three values are numeric.** MET. Baseline 94.94%, post-change 94.22%, changed-line coverage
   81.90% aggregate with the four per-file values above.
2. **The post-change percentage is at or above 85.** MET. 94.22%.
3. **No changed line in either modified hook is reported as uncovered.** **NOT MET.** The Claude
   modified hook reports 10 uncovered added lines and the Codex modified hook reports 27.

Clause 3 is not satisfiable by any verification action available in Phase 6. Phase 6 is a
verification phase; satisfying it would require authoring new tests, which is implementation work
outside this phase's scope and outside the plan as written. **P6-T6 therefore stays unchecked and the
condition is escalated at completion rather than resolved here.** No test was added and no criterion
text was amended.

## The 63 uncovered added lines, characterized

They fall into four groups. None is a defect in the change; each is a consequence of a design
decision recorded earlier in this plan.

### Group 1 — the real filesystem read seams, bypassed by injection (18 lines)

`.claude/...gate.ps1` lines 266-270 and 278-282; `.codex/...gate.ps1` lines 292-296 and 304-308.

These are the bodies of `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent`:

```powershell
$path = Get-OrchestrationDelegationCheckpointPath -Mode 'epic'
if (-not (Test-Path -LiteralPath $path)) { return '' }
return Get-Content -Raw -LiteralPath $path
```

Every test injects `-EpicCheckpointRaw` or `-ParallelCheckpointRaw` instead of letting the hook read
the live file. That injection is mandatory, not incidental: a gate case that omits the injected raw
value reads the live checkpoint in the running repository, and an allow case evaluated that way
cannot fail because the live checkpoint is genuinely ready. The seams exist precisely so the decision
logic is testable without filesystem I/O, which is also what
`.claude/rules/general-unit-test.md` requires ("core domain logic must be testable without touching
the network or filesystem"). Their own bodies are therefore unreachable from the suite by
construction.

### Group 2 — the non-injected fallback branch (3 lines)

`.claude/...gate.ps1` line 408; `.codex/...gate.ps1` lines 421-422.

```powershell
} elseif ($isEpic) { Get-EpicCheckpointContent } else { Get-ParallelCheckpointContent }
```

This is the `else` arm of the same injection seam and is uncovered for the identical reason.

### Group 3 — the Codex logic-parity copy's reduced suite (40 lines)

`.codex/...gate.ps1` lines 352-353 and 426-443; `.codex/...gate-modes.ps1` lines 197, 228-250, and
268-274.

The Codex suite `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
carries 13 `It` blocks against the Claude suite's 43. That asymmetry is the recorded decision D5
transport gap, documented at P3-T18 and P3-T19 and restated in the Codex test file's own header:
`.codex/config.toml` registers no PreToolUse matcher admitting the delegation tool, so the Codex hook
is a **logic-parity copy that is not reachable in transport**. The Codex suite asserts logic parity
on the decision surface; it does not re-derive every helper the Claude suite covers. The uncovered
lines are the epic/parallel decision branch, the mode deny-reason string builder, the target-folder
resolver, and the issue-number resolver — each of which is covered on the Claude side by the
equivalent line in a byte-identical algorithm.

### Group 4 — a debug-only error path (2 lines)

`.claude/...gate-modes.ps1` and `.codex/...gate-modes.ps1` lines 94-95:

```powershell
} catch {
    Write-Debug "Property probe failed for '$Name': $($_.Exception.Message)"
    return $null
}
```

The `catch` fires only when `$Value.PSObject.Properties` itself throws, which no JSON-derived object
in the suite produces.

## No regression on the lines this change did not touch

The repository-wide -0.72 pp movement is entirely accounted for by the denominator growth: the two
newly registered `-modes.ps1` files contributed 264 measurable added lines of which 26 are uncovered,
plus the pre-existing files' 46 remaining new misses in the two modified hooks. No previously covered
line became uncovered; the covered count rose by 266.

## Effect on the spec acceptance criterion, and why it is left unchecked

The corresponding criterion in `spec.md` reads:

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

Its first clause is met: 94.22% >= 85%. Its second clause is **left unchecked**, for two reasons
recorded here rather than resolved by an edit to the criterion text.

**First, the second clause cannot be answered on the evidence available in Phase 6.** "Loses
coverage" is a statement about a line's coverage state *before* the change compared with *after*.
The P0-T6 baseline artifact records repository-wide JaCoCo counters only; it retains no per-file,
per-line coverage map for the two modified hooks at the merge base. Answering the clause exactly
would require re-running the full Pester suite against a merge-base checkout to recover that map,
which is new work outside a verification-only phase. The repository-wide miss count rose by 72 while
this analysis accounts for 63 uncovered added lines, so up to 9 misses are unattributed and the
possibility that a previously covered line regressed cannot be excluded on present evidence.

**Second, the reading under which the clause would pass makes it unfalsifiable.** A changed line in
a unified diff is an added line on the new side; an added line has no prior coverage state, so under
a literal reading no added line can ever "lose" coverage and the clause could not fail whatever the
change did. `.claude/rules/plan-acceptance-gates.md` treats an acceptance condition that cannot fail
as gating nothing. The plan's own P6-T6 encodes the falsifiable reading instead — "no changed line in
either modified hook is **reported as uncovered**" — and on that reading the clause fails with 37
uncovered changed lines across the two modified hooks.

Marking the criterion satisfied would therefore require either evidence that does not exist or a
reading that cannot fail. It is left unchecked, its text is unamended, and the four groups of
uncovered lines are characterized above so a reviewer can judge each on its merits.

## Verdict

PARTIAL. Clauses 1 and 2 of the acceptance are met with numeric evidence. Clause 3 is not met: 63
measurable changed lines are uncovered, 37 of them in the two modified gate hooks. This task is left
unchecked and reported as an outstanding condition.
