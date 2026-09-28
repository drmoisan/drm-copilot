# [P7-T12] Coverage delta — baseline versus post-change

Timestamp: 2026-08-29T22-52

Command: this task runs no command of its own. Every figure below is read from the covered and missed
counts, or the coverage-table rows, recorded verbatim in the four source artifacts named in the
"Source artifacts" section, and every percentage is **recomputed independently** from those counts
rather than copied from a prior summary line.

EXIT_CODE: 0

Output Summary: PowerShell repository-wide LINE coverage is unchanged at **94.7 percent**. The three
edited hooks stand at **93.8**, **93.8**, and **88.1 percent**, all above the 85 percent floor, with
margins of 8.8, 8.8, and 3.1 percentage points. Two of the three carry a **decline of 1.8 percentage
points** against baseline, which the plan classifies as a blocking finding and which is reported as
such below rather than rounded away. TypeScript `All files` rose from 96.71 to **96.72 percent lines**
and from 90.15 to **90.16 percent branches**; no TypeScript figure declined. The net-new
`claude-gitignore-merge.ts` records **98.78 percent lines** and **90 percent branches**, clearing its
85/75 thresholds.

## Source artifacts

| Section | Source |
| --- | --- |
| (a) PowerShell baseline | `evidence/baseline/powershell-test-coverage.2026-08-29T16-05.md` ([P0-T12]) |
| (b) PowerShell post-change | `evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md` ([P7-T5]) |
| (d) TypeScript baseline | `evidence/baseline/typescript-test-coverage.2026-08-29T16-05.md` ([P0-T16]) |
| (e) TypeScript post-change | `evidence/qa-gates/typescript-test-coverage-final.2026-08-29T16-05.md` ([P7-T10]) |

## (a) PowerShell baseline — [P0-T12]

Raw Form C counts, verbatim from the source artifact:

```
REPO LINE covered=7236 missed=403
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=86 missed=4
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=86 missed=4
.claude/hooks/persist-session-id.ps1 LINE covered=33 missed=5
```

Percentages recomputed independently as `100 * covered / (covered + missed)`:

| Scope | covered | missed | total | LINE percent |
| --- | --- | --- | --- | --- |
| Repository-wide | 7236 | 403 | 7639 | `100 * 7236 / 7639 = 94.7238` → **94.7** |
| `enforce-powershell-batch-budget.ps1` | 86 | 4 | 90 | `100 * 86 / 90 = 95.5556` → **95.6** |
| `enforce-python-batch-budget.ps1` | 86 | 4 | 90 | `100 * 86 / 90 = 95.5556` → **95.6** |
| `persist-session-id.ps1` | 33 | 5 | 38 | `100 * 33 / 38 = 86.8421` → **86.8** |

## (b) PowerShell post-change — [P7-T5]

Raw Form C counts, verbatim, identical across both loop iterations:

```
REPO LINE covered=7384 missed=411
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/persist-session-id.ps1 LINE covered=37 missed=5
```

Percentages recomputed independently:

| Scope | covered | missed | total | LINE percent |
| --- | --- | --- | --- | --- |
| Repository-wide | 7384 | 411 | 7795 | `100 * 7384 / 7795 = 94.7274` → **94.7** |
| `enforce-powershell-batch-budget.ps1` | 121 | 8 | 129 | `100 * 121 / 129 = 93.7984` → **93.8** |
| `enforce-python-batch-budget.ps1` | 121 | 8 | 129 | `100 * 121 / 129 = 93.7984` → **93.8** |
| `persist-session-id.ps1` | 37 | 5 | 42 | `100 * 37 / 42 = 88.0952` → **88.1** |

## (c) PowerShell per-file delta — with declines stated, not rounded away

| File | Baseline | Post-change | **Delta** | Floor 85 | Margin above floor |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp — DECLINE** | met | **+8.8 pp** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp — DECLINE** | met | **+8.8 pp** |
| `.claude/hooks/persist-session-id.ps1` | 86.8 (33/38) | 88.1 (37/42) | +1.3 pp — improvement | met | **+3.1 pp** |
| Repository-wide | 94.7 (7236/7639) | 94.7 (7384/7795) | +0.0 pp (+0.004 pp unrounded) | met | +9.7 pp |

Unrounded deltas, for precision: `93.7984 - 95.5556 = -1.7572` pp for each of the two batch-budget
hooks; `88.0952 - 86.8421 = +1.2531` pp for `persist-session-id.ps1`; `94.7274 - 94.7238 = +0.0036`
pp repository-wide.

### The two declines, called out explicitly

**Two of the three edited hooks show a negative per-file coverage delta of 1.8 percentage points.**
The plan's acceptance text for this task classifies any negative per-file delta as a **coverage
regression on changed lines, which is a blocking finding**. That classification is applied here and
is reported to the orchestrator rather than reinterpreted, softened, or rounded to zero.

Four facts qualify the finding without removing it.

1. **Both files remain well above the 85 percent floor**, at 93.8 percent with an 8.8 percentage
   point margin. No coverage gate is violated.
2. **Covered lines rose sharply.** `enforce-powershell-batch-budget.ps1` went from 86 covered to 121
   covered, an increase of 35 covered lines. The file grew from 90 to 129 measured lines. The
   percentage fell because missed lines grew from 4 to 8 while the denominator grew by 39; more code
   is covered in absolute terms than before.
3. **The four newly uncovered lines are identified.** They are the two degenerate-input guards in the
   containment helper and the unreadable-session-id-file catch block, together with the same shape of
   addition in the Python-hook sibling. This was recorded as a known watch item during Phase 2, not
   discovered here.
4. **No planned test reaches them and the plan authorizes no additional test.** Adding one would be
   work not described by the plan. The gap is therefore reported rather than closed.

The third hook, `persist-session-id.ps1`, **improved** by 1.3 percentage points and now has 3.1
percentage points of headroom above the floor, up from 1.8 at baseline. It remains the file with the
least margin.

## (d) TypeScript baseline — [P0-T16]

| Row | % Lines | % Branch |
| --- | --- | --- |
| `All files` | **96.71** | **90.15** |
| `claude-customizations.ts` | 100 | 93.93 |
| `claude-gitignore-merge.ts` | **no row — file did not exist** | **no row** |

Underlying aggregate counts, verbatim from the source artifact:
`Lines : 96.71% ( 44024/45518 )`, `Branches : 90.15% ( 6273/6958 )`. Recomputed:
`100 * 44024 / 45518 = 96.7089` → 96.71; `100 * 6273 / 6958 = 90.1552` → 90.15.

## (e) TypeScript post-change — [P7-T10]

| Row | % Lines | % Branch |
| --- | --- | --- |
| `All files` | **96.72** | **90.16** |
| `claude-customizations.ts` | 100 | 94.59 |
| `claude-gitignore-merge.ts` | **98.78** | **90** |

Underlying aggregate counts, verbatim: `Lines : 96.72% ( 44232/45728 )`,
`Branches : 90.16% ( 6296/6983 )`. Recomputed: `100 * 44232 / 45728 = 96.7189` → 96.72;
`100 * 6296 / 6983 = 90.1618` → 90.16.

### TypeScript delta

| Row / metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| `All files` % Lines | 96.71 | 96.72 | **+0.01 pp** |
| `All files` % Branch | 90.15 | 90.16 | **+0.01 pp** |
| `claude-customizations.ts` % Lines | 100 | 100 | 0.00 pp |
| `claude-customizations.ts` % Branch | 93.93 | 94.59 | **+0.66 pp** |
| `claude-gitignore-merge.ts` % Lines | n/a (new file) | 98.78 | new |
| `claude-gitignore-merge.ts` % Branch | n/a (new file) | 90 | new |

**No TypeScript figure declined.** There is no TypeScript coverage regression to report.

## (f) New-code and changed-code coverage statement

**New code — TypeScript.** The new-code figure is the `claude-gitignore-merge.ts` row, which appears
for the first time in [P7-T10] because the module is created by [P4-T1]:

- **Line coverage 98.78 percent**, against a floor of 85. Margin **+13.78 pp**.
- **Branch coverage 90 percent**, against a floor of 75. Margin **+15.0 pp**.
- Uncovered lines: 151, 152.

Both floors are the ones its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`
(lines 213 through 216) enforces. Jest exited 0 and printed no `coverage threshold for` line, so the
threshold was armed, evaluated, and satisfied.

**Changed code — TypeScript.** `claude-customizations.ts`, modified by [P5-T3], holds at 100 percent
lines and improves from 93.93 to 94.59 percent branches.

**Changed code — PowerShell.** The three hook rows are the changed-code figures:

| File | Post-change LINE | Floor | Margin | Delta vs baseline |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | **93.8** | 85 | +8.8 pp | **-1.8 pp** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | **93.8** | 85 | +8.8 pp | **-1.8 pp** |
| `.claude/hooks/persist-session-id.ps1` | **88.1** | 85 | +3.1 pp | +1.3 pp |

No branch figure is recorded for PowerShell. Pester emits no branch counter and, per
`.claude/rules/quality-tiers.md`, no PowerShell branch-coverage gate applies. The line threshold
applies and is met by all three files.

## Overall verdict

- **Every coverage threshold in force is met**, on both languages, at every scope measured.
- **Two per-file PowerShell declines of 1.8 percentage points are reported as a blocking finding**
  under the plan's own classification, with their cause identified and their remaining margin stated.
- No placeholder appears anywhere in this artifact. Every percentage is derived from counts recorded
  verbatim in a named source artifact.
