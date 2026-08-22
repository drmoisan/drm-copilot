# QA gate — File-size ceiling (AC-12) (#501)

Timestamp: 2026-08-22T00-15

Task: [P5-T4]

Command:

```powershell
Get-ChildItem .claude/hooks/*.ps1, .claude/lib/hook-payload/*.psm1, tests/scripts/claude-hooks/*.ps1, tests/scripts/claude-lib/hook-payload/*.ps1 |
    ForEach-Object { [pscustomobject]@{ Name = $_.Name; Lines = (Get-Content $_.FullName).Count } } |
    Where-Object Lines -gt 500
```

EXIT_CODE: 0

## Result — run 1 (post-migration, pre-Phase-7 format)

```
rows over 500: 0
```

The filter returned no rows: no measured production or test file exceeds the 500-line ceiling.

## Largest eight measured files (headroom check)

```
Name                                      Lines
----                                      -----
HookPayload.psm1                            494
validate-orchestrator-output.Tests.ps1      490
HookPayload.Tests.ps1                       487
validate-feature-review-coverage.ps1        459
enforce-epic-merge-gate.Tests.ps1           455
enforce-completion-consistency.Tests.ps1    455
enforce-parallel-cohort-barrier.Tests.ps1   455
enforce-epic-merge-gate.ps1                 452
```

`validate-orchestrator-output.Tests.ps1` and `validate-feature-review-coverage.ps1` are SubagentStop-surface files, out of this feature's scope and unmodified by it; they are in the measured glob but not in the change set.

## Plan-mandated per-file budgets

| File | Budget | Actual |
| --- | --- | --- |
| `.claude/lib/hook-payload/HookPayload.psm1` | < 500 ([P1-T1]) | 494 |
| `.claude/hooks/enforce-pr-author-skill.ps1` | <= 460 ([P2-T2]) | 304 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | < 500 ([P2-T2]) | 228 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | <= 480 ([P2-T1]) | 455 |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | <= 450 ([P4-T2]) | 283 |
| `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` | <= 300 ([P4-T2]) | 278 |

Every plan-mandated budget holds.

Output Summary: The AC-12 ceiling check returns no rows. Zero of the measured files exceed 500 lines; the largest is `HookPayload.psm1` at 494. Every per-file budget the plan set for this migration holds. This measurement is re-run in Phase 7 if the format stage modifies any measured file, and that re-run is appended below.

## Result — run 2 (post-Phase-7 format re-measurement)

Timestamp: 2026-08-22T00-50

The [P7-T1] format stage modified zero PowerShell files, so the plan's re-measurement condition ("re-run after any Phase 7 pass in which P7-T1 modifies a measured file") was not triggered. The measurement was re-run anyway for completeness.

Command: identical to run 1.

EXIT_CODE: 0

Output:

```
post-format rows over 500: 0
```

The filter again returns no rows. AC-12 holds after the final format pass.
