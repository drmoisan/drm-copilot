# Coverage delta — baseline versus post-remediation ([P5-T14])

Timestamp: 2026-08-30T01-49
Task: [P5-T14]

Command: this task runs no new measurement. Every value below is read from a named source artifact
already on disk, and every percentage is recomputed independently from the covered and missed counts
recorded in those artifacts rather than copied from a prior summary line.

Source artifacts, all rooted at
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`:

```
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/powershell-suite-baseline.2026-08-29T23-07.md   ([P0-T10])
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/python-suite-baseline.2026-08-29T23-07.md       ([P0-T11])
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/typescript-test-coverage.2026-08-29T23-07.md    ([P0-T16])
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/qa-gates/powershell-suite-final.2026-08-29T23-07.md                  ([P5-T5])
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/qa-gates/python-suite-final.2026-08-29T23-07.md                      ([P5-T6])
docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/qa-gates/typescript-test-coverage-final.2026-08-29T23-07.md          ([P5-T11])
```

EXIT_CODE: 0
ExpectedExitCode: 0

The exit code records that all six named artifacts were located and read in full. No subprocess is
invoked by this task.

## (a) PowerShell baseline — LINE covered, missed, and derived percentage

| Hook | Source | covered | missed | total | Derived LINE percent |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | [P0-T10] | 121 | 8 | 129 | 100 * 121 / 129 = **93.8** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | [P0-T11] | 121 | 8 | 129 | 100 * 121 / 129 = **93.8** |

## (b) PowerShell post-remediation — LINE covered, missed, and derived percentage

| Hook | Source | covered | missed | total | Derived LINE percent |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | [P5-T5] | 123 | 6 | 129 | 100 * 123 / 129 = **95.3** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | [P5-T6] | 123 | 6 | 129 | 100 * 123 / 129 = **95.3** |

## (c) PowerShell per-file delta, and the changed-lines regression check

| Hook | Baseline percent | Post percent | Delta | covered delta | missed delta |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 93.8 | 95.3 | **+1.5 points** | +2 | -2 |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 93.8 | 95.3 | **+1.5 points** | +2 | -2 |

**Did any previously covered line become uncovered? No, in neither hook.**

The reasoning is arithmetic rather than assertion. In each hook the instrumented total is 129 lines
both before and after, unchanged because decision D-1 was a single-line in-place replacement that
added and removed no line ([P1-T4] and [P2-T4] each confirmed the file's line count unchanged at 457
and 454 respectively). Against a fixed total of 129, the covered count rose by exactly 2 and the
missed count fell by exactly 2. If any previously covered line had become uncovered, that regression
would have had to be offset by three or more newly covered lines to produce a net movement of two,
and the Form D per-line records identify exactly two lines that changed state in each file — 154 and
155 in the PowerShell hook, 151 and 152 in the Python hook — each moving from `mi>0, ci=0` to
`mi=0, ci>0`. There is no third line available to absorb a regression. The changed-lines gate that
`.claude/rules/general-unit-test.md` states, and which is the only coverage regression that blocks,
is therefore satisfied in both hooks.

Both post-remediation percentages are at or above the 85 percent line floor. No branch figure is
recorded for PowerShell: Pester emits no branch counter, and per `.claude/rules/quality-tiers.md` no
PowerShell branch gate applies.

**Measurement-scope caveat.** All four PowerShell figures are scoped measurements.
`Invoke-PoshQCTest` narrows `Run.Path` to the supplied `-ScanFolders` while leaving
`CodeCoverage.Path` at its full allow-list, so `PreToolUseSchema.Contract.Tests.ps1` did not run and
contributed nothing to any of the four covered counts. The baseline and post-remediation figures were
produced by the same scoped procedure, so they are directly comparable to each other. They are not
the same quantity as an unscoped run. The scan was not widened to make any number match.

## (d) TypeScript — baseline and post-remediation line and branch percentages

| Row | Metric | Baseline [P0-T16] | Post [P5-T11] | Delta |
| --- | --- | --- | --- | --- |
| `All files` | % Lines | 96.72 | 96.72 | **0.00** |
| `All files` | % Branch | 90.16 | 90.17 | **+0.01** |
| `claude-gitignore-merge.ts` | % Lines | 98.78 | 98.79 | **+0.01** |
| `claude-gitignore-merge.ts` | % Branch | 90 | 95 | **+5** |

Corroborating absolute counts from the aggregate summary blocks: baseline lines `44232/45728`,
post-remediation lines `44234/45730`; baseline branches `6296/6983`, post-remediation branches
`6297/6983`. Recomputed: 100 * 44234 / 45730 = 96.72; 100 * 6297 / 6983 = 90.17. Both agree with the
`All files` table row.

No TypeScript metric declined. Every delta is zero or positive.

The `claude-gitignore-merge.ts` figures clear the `coverageThreshold` entry armed at
`extensions/drm-copilot/jest.config.cjs:213-216` — 85 lines and 75 branches — with margin, and no
`coverage threshold for` line was printed on the post-remediation run.

## (e) New-and-changed-code statement

Two distinct movements account for every delta above.

1. **The four Form D catch-body lines moved from uncovered to covered.** These are the B-3 subject.

   | File | Line | Baseline | Post-remediation |
   | --- | --- | --- | --- |
   | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 154 | `mi=2 ci=0` | `mi=0 ci=2` |
   | `.claude/hooks/enforce-powershell-batch-budget.ps1` | 155 | `mi=1 ci=0` | `mi=0 ci=1` |
   | `.claude/hooks/enforce-python-batch-budget.ps1` | 151 | `mi=2 ci=0` | `mi=0 ci=2` |
   | `.claude/hooks/enforce-python-batch-budget.ps1` | 152 | `mi=1 ci=0` | `mi=0 ci=1` |

   The two PowerShell rows come from [P0-T10] and [P5-T5]; the two Python rows from [P0-T11] and
   [P5-T6]. This movement is the whole of the +2 covered / -2 missed delta in each hook, and it is
   the alternative proof that the B-3 fail-before exception dossier rests on.

2. **The `claude-gitignore-merge.ts` branch figure rose from 90 to 95 because the line-126 arm became
   exercised.** Before the remediation no test supplied an opening sentinel with no closing sentinel,
   so the `endOffset === -1` arm of the conditional at line 126 was never taken. The [P3-T1] test
   `preserves content following an opening sentinel that has no closing sentinel` is the first input
   of that shape, and it is the only change to that file's test coverage in this cycle.

The file's line percentage rose by 0.01 for a separate and non-coverage reason: the D-2 comment
update added two covered lines, moving the module from 164 to 166 lines, so numerator and denominator
both rose. The file's uncovered range shifted from `151-152` to `153-154` — the same two statements,
displaced by those two added lines. They are the `appendManagedBlock` trailing-blank loop, advisory
finding N-6, explicitly out of scope and expected to remain uncovered. No task asserts a rise
attributable to them.

Output Summary: PowerShell, both hooks, scoped per-file LINE coverage rose from **93.8** (covered
121, missed 8) to **95.3** (covered 123, missed 6), a delta of **+1.5 points** each, both above the
85 floor; no previously covered line became uncovered in either hook, established arithmetically
against a fixed 129-line total. No PowerShell branch figure is recorded, because Pester emits no
branch counter. TypeScript `All files` lines held at **96.72** (delta 0.00) and branches rose from
90.16 to **90.17** (+0.01); `claude-gitignore-merge.ts` lines rose from 98.78 to **98.79** (+0.01)
and branches from 90 to **95** (+5). No metric declined anywhere. The four Form D catch-body lines
moved from uncovered to covered, and the merge module's branch rise is attributable to the line-126
arm becoming exercised.
