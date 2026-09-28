# QA Gate — Coverage Comparison, Baseline vs Post-Change — Issue #440

Timestamp: 2026-08-08T22-50

Task: [P5-T8]

Branch: `feature/parallel-enforcement-hooks-440`

Working directory: repository root (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`)

## Artifacts Compared

| Role | Artifact |
| --- | --- |
| PowerShell baseline | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/powershell-tests-coverage.2026-08-08T20-57.md` |
| PowerShell post-change | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-tests-coverage.2026-08-08T22-42.md` |
| Python baseline | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/baseline/python-tests-coverage.2026-08-08T20-57.md` |
| Python post-change | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/python-tests-coverage.2026-08-08T22-48.md` |
| PowerShell per-file coverage (this task) | `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-per-file-coverage.2026-08-08T22-50.xml` |

## Mandatory Per-File PowerShell Command

Command:

```
pwsh -NoProfile -Command '$r = Invoke-Pester -Configuration @{ Run = @{ Path = @("tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1","tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1","tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1"); PassThru = $true }; CodeCoverage = @{ Enabled = $true; Path = @(".claude/hooks/enforce-parallel-cohort-barrier.ps1",".claude/hooks/enforce-parallel-worktree-removal-gate.ps1",".claude/hooks/enforce-epic-invocation-origin.ps1"); OutputPath = "docs/features/active/2026-08-07-parallel-enforcement-hooks-440/evidence/qa-gates/powershell-per-file-coverage.2026-08-08T22-50.xml" } }; $exec = @($r.CodeCoverage.CommandsExecuted); $miss = @($r.CodeCoverage.CommandsMissed); foreach ($f in (@($exec) + @($miss) | Select-Object -ExpandProperty File -Unique)) { $e = @($exec | Where-Object { $_.File -eq $f }).Count; $m = @($miss | Where-Object { $_.File -eq $f }).Count; Write-Output ("PERFILE {0} analyzed={1} executed={2} pct={3:N2}" -f $f, ($e + $m), $e, (100 * $e / ($e + $m))) }; Write-Output ("FAILED=" + $r.FailedCount); if ($r.FailedCount -gt 0) { exit 1 } else { exit 0 }'
```

EXIT_CODE: 0

Invocation notes, each a required property of the command as planned:

- Invoked through the Bash tool with the **entire `-Command` argument in single quotes**, so Git Bash expanded none of the `$` tokens (`$r`, `$exec`, `$miss`, `$f`, `$e`, `$m`, `$_`).
- `Run.PassThru = $true` was set, which is what makes the per-file `CommandsExecuted` / `CommandsMissed` objects available. Pester's console coverage line reports only the aggregate `Covered 93.42% / 75%. 319 analyzed Commands in 3 Files`, which cannot support a per-file threshold claim and could mask a per-file failure.
- `CodeCoverage.OutputPath` was directed at the canonical evidence path, so Pester wrote no `coverage.xml` into the repository root. Verified: the repository-root `coverage.xml` is a pre-existing **tracked** file (committed `9bfe62e1`, 2026-07-11) with mtime `Aug 8 20:53`, which precedes this run at `22:47`; `git status --porcelain coverage.xml` reports it unmodified. The new XML was written to `evidence/qa-gates/powershell-per-file-coverage.2026-08-08T22-50.xml` (23,863 bytes).
- The explicit `exit` was required because `Invoke-Pester` defaults `Run.Exit` to `$false`; without it a test failure would still have recorded `EXIT_CODE: 0`. `FAILED=0`, so the success branch `exit 0` was taken.

### Raw Output — three `PERFILE` lines verbatim plus `FAILED=`

```
Tests Passed: 123, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Covered 93.42% / 75%. 319 analyzed Commands in 3 Files.
PERFILE C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee\.claude\hooks\enforce-epic-invocation-origin.ps1 analyzed=69 executed=62 pct=89.86
PERFILE C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee\.claude\hooks\enforce-parallel-cohort-barrier.ps1 analyzed=174 executed=167 pct=95.98
PERFILE C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee\.claude\hooks\enforce-parallel-worktree-removal-gate.ps1 analyzed=76 executed=69 pct=90.79
FAILED=0
```

## PowerShell — Per-File New/Changed-Code Coverage (the authoritative per-file numbers)

| Production file | analyzed commands | executed | missed | line/command coverage | threshold | status |
| --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (new, P1-T1) | 174 | 167 | 7 | **95.98%** | >= 85% | **PASS** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (new, P1-T3) | 76 | 69 | 7 | **90.79%** | >= 85% | **PASS** |
| `.claude/hooks/enforce-epic-invocation-origin.ps1` (extended, P2-T1) | 69 | 62 | 7 | **89.86%** | >= 85% | **PASS** |
| Aggregate across the three files | 319 | 298 | 21 | 93.42% | >= 85% | PASS |

All three files clear the >= 85% threshold individually, not merely in aggregate. 123 tests ran across the three suites with 0 failures.

BRANCH: not emitted by PoshQC/Pester coverage output

The repository's PowerShell coverage tooling emits no BRANCH counter: the JaCoCo-format document produced by the suite contains exactly four top-level `counter` elements — `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` — and the `Invoke-Pester` result object exposes command-level executed/missed data only. Line/command coverage is therefore the authoritative PowerShell numeric and this explicit absence note is the required substitute per plan Binding Constraint 7 (precedent: `docs/features/active/2026-07-09-subagent-tree-mcp-and-dropdown-334/evidence/qa-gates/coverage-delta.2026-07-09T09-59.md`). It is not a placeholder for a metric that is available but unrecorded.

### Why the per-file numbers were NOT read from `artifacts/pester/powershell-coverage.xml`

`mcp__drm-copilot__run_poshqc_test` executes the **installed extension bundle's** `resources/templates/run-poshqc-test.ps1`, which imports the installed bundle's `PoshQC` module and that module's module-root-relative `settings/pester.runsettings.psd1`. P2-T4 edited the two **in-repo** copies of `pester.runsettings.psd1`, so the registration takes effect only for runs made from a republished bundle and does not change the same-session MCP run's coverage denominator. `artifacts/pester/powershell-coverage.xml` from the [P5-T3] run therefore contains none of these three files, which is why the plan mandates this dedicated repo-local run instead. Confirming evidence: the aggregate LINE/INSTRUCTION counters in the [P5-T3] run are byte-identical to the P0-T4 baseline (3148/189 and 4316/278), which would be impossible had three files entered the denominator.

### PowerShell aggregate suite coverage — baseline vs post-change

| Counter | Baseline (P0-T4) | Post-change (P5-T3) | Delta | Threshold | Status |
| --- | --- | --- | --- | --- | --- |
| LINE | 94.34% (3148 / 189 / 3337) | **94.34%** (3148 / 189 / 3337) | 0.00 pp | >= 85% | PASS |
| INSTRUCTION (commands) | 93.95% (4316 / 278 / 4594) | **93.95%** (4316 / 278 / 4594) | 0.00 pp | >= 85% | PASS |
| BRANCH | not emitted | not emitted | n/a | n/a | n/a |

No regression: the aggregate is unchanged for the denominator reason above.

### PowerShell no-regression-on-changed-lines determination

Regression on changed lines is structurally impossible for these three files, and the changed lines are affirmatively covered:

- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` did not exist at baseline; every line in each is a changed line, and each file measures at 95.98% and 90.79% respectively.
- `.claude/hooks/enforce-epic-invocation-origin.ps1` was **not** in the `CodeCoverage.Path` list at baseline. `git diff -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1` shows all three entries, including this one, are newly appended by P2-T4, so no prior per-file figure exists to regress against. Its post-change figure is 89.86%, above threshold. Its P2-T1 changes are two additive edits (two `$script:GatedSubagentTypes` members and a target-selected parallel deny-reason variant), all exercised by the 14 appended `Context` cases, which pass.

## Python — Baseline vs Post-Change

| Metric | Baseline (P0-T8) | Post-change (P5-T7) | Delta | Threshold | Status |
| --- | --- | --- | --- | --- | --- |
| **Line coverage** | 91.82% (12432 / 13539) | **91.88%** (12541 / 13649) | **+0.06 pp** | >= 85% | **PASS** |
| **Branch coverage** | 83.80% (4190 / 5000) | **83.96%** (4245 / 5056) | **+0.16 pp** | >= 75% | **PASS** |
| Combined (pytest-cov `Cover`) | 89.66% (prints 90%) | 89.74% (prints 90%) | +0.08 pp | n/a | n/a |
| Tests passed / failed | 3007 / 0 | 3038 / 0 | +31 / 0 | — | PASS |

Both figures were read the way the baseline read them — separated statement and branch values from `coverage json` totals (`percent_statements_covered`, `percent_branches_covered`) — because the pytest-cov `TOTAL` row's `Cover` column is the **combined** statement-plus-branch metric, not the line figure. Both separated metrics rose, so there is no aggregate Python regression.

### Python new/changed-code coverage

| File | Post-change | Baseline | Status |
| --- | --- | --- | --- |
| `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (new, P3-T1) | **99%** (108 stmts, 1 missed at line 324; 56 branches, 1 partial) | did not exist | PASS, >= 85% |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (edited, P3-T3) | **97%** (84 stmts, 2 missed at lines 229, 268; 34 branches, 2 partial) | 97% (82 stmts, 2 missed) | PASS, no regression |

No regression on changed lines: P3-T3's two added statements raised the validator's statement count from 82 to 84 while the missed count stayed at 2, so both added statements are covered and the file's percentage is unchanged. The new helper module's only uncovered statement is line 324, leaving it at 99%.

## Threshold Verdict

| Gate | Requirement | Observed | Verdict |
| --- | --- | --- | --- |
| PowerShell per-file line/command coverage, `enforce-parallel-cohort-barrier.ps1` | >= 85% | 95.98% | PASS |
| PowerShell per-file line/command coverage, `enforce-parallel-worktree-removal-gate.ps1` | >= 85% | 90.79% | PASS |
| PowerShell per-file line/command coverage, `enforce-epic-invocation-origin.ps1` | >= 85% | 89.86% | PASS |
| PowerShell aggregate line / command coverage | >= 85%, no regression | 94.34% / 93.95%, 0.00 pp delta | PASS |
| PowerShell BRANCH | n/a — not emitted by tooling | explicit absence recorded | n/a |
| Python line coverage | >= 85%, no regression | 91.88%, +0.06 pp | PASS |
| Python branch coverage | >= 75%, no regression | 83.96%, +0.16 pp | PASS |
| No coverage regression on changed lines | required | PowerShell: new files fully changed and above threshold; extended hook newly measured at 89.86%. Python: both added validator statements covered; new helper at 99% | PASS |
| This task's dedicated Pester run | 0 failures | `FAILED=0`, 123 tests passed | PASS |

**Overall coverage verdict: PASS.** No threshold is missed, so `remediation-required` is NOT recorded for coverage.

## Outstanding Item Recorded for Completeness (not a coverage failure)

The [P5-T3] full Pester run exits 1 because of one pre-existing, out-of-scope failure in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (`allows gh pr create --body-file artifacts/pr_body_12.md when context exists`), which reads the live gitignored `artifacts/orchestration/orchestrator-state.json` instead of a mocked seam. It is identical to the failure recorded in the P0-T4 baseline, is attributable to none of this feature's files, and is not a coverage finding. It is recorded, not fixed, per the execution directive.

Output Summary: PASS — every coverage threshold met, `remediation-required` NOT recorded. Dedicated repo-local Pester run: EXIT_CODE 0, 123 tests passed, `FAILED=0`. Per-file line/command coverage: `enforce-parallel-cohort-barrier.ps1` **95.98%** (174 analyzed / 167 executed), `enforce-parallel-worktree-removal-gate.ps1` **90.79%** (76 / 69), `enforce-epic-invocation-origin.ps1` **89.86%** (69 / 62) — all three individually >= 85%, aggregate 93.42% across 319 commands. BRANCH: not emitted by PoshQC/Pester coverage output. PowerShell aggregate suite coverage unchanged from baseline at 94.34% line / 93.95% command (the [P5-T3] MCP run uses the installed bundle's runsettings, so the three files are outside that denominator, which is why the per-file numbers come from this dedicated run). Python line coverage 91.82% -> **91.88%** (+0.06 pp, >= 85%) and branch coverage 83.80% -> **83.96%** (+0.16 pp, >= 75%), both improved; 3007 -> 3038 tests passed with 0 failures. New/changed-code coverage: new helper module 99%, edited validator 97% with both added statements covered, both new hooks fully-changed files above threshold, extended hook newly measured above threshold. No regression on changed lines in either language.
