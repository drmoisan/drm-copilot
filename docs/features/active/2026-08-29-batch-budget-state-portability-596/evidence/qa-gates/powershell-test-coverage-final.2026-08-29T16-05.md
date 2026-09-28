# [P7-T5] PowerShell test and coverage — final QA loop (self-hosted Form A + Form B + Form C)

Timestamp: 2026-08-29T22-22

Command: three commands, run in this order. The absolute prefix actually used for each was
`cd /c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5 && `.

1. Form A, unscoped, exactly as written in the plan:
   `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"`
2. Form B, exactly as written in the plan's "Form B" paragraph:
   `pwsh -NoProfile -Command '[xml]$junit = Get-Content -LiteralPath "artifacts/pester/pester-junit.xml" -Raw; $root = $junit.SelectSingleNode("/*"); "root={0} tests={1} failures={2}" -f $root.Name, $root.GetAttribute("tests"), $root.GetAttribute("failures"); $junit.SelectNodes("//testcase[failure]") | ForEach-Object { $_.name }'`
3. Form C, exactly as written in the plan's "Form C" paragraph:
   `pwsh -NoProfile -Command '[xml]$report = Get-Content -LiteralPath "artifacts/pester/powershell-coverage.xml" -Raw; $rootLine = @($report.report.counter) | Where-Object { $_.type -eq "LINE" }; "REPO LINE covered={0} missed={1}" -f $rootLine.covered, $rootLine.missed; foreach ($leaf in @(".claude/hooks/enforce-powershell-batch-budget.ps1", ".claude/hooks/enforce-python-batch-budget.ps1", ".claude/hooks/persist-session-id.ps1")) { foreach ($pkg in @($report.report.package)) { foreach ($sf in @($pkg.sourcefile)) { $full = ($pkg.name + "/" + $sf.name).Replace("\", "/"); if ($full.EndsWith("/" + $leaf)) { $c = @($sf.counter) | Where-Object { $_.type -eq "LINE" }; "{0} LINE covered={1} missed={2}" -f $leaf, $c.covered, $c.missed } } } }'`

EXIT_CODE: 2

Output Summary: The Form A run discovered 3904 tests across 160 files and exited with process code
**2** because 2 tests failed. **This task's stated acceptance of `EXIT_CODE: 0` and a failed count of
0 is NOT met.** The two failures are byte-identical in name to the pair recorded at the [P0-T12]
baseline and are classified pre-existing (evidence in
`evidence/qa-gates/powershell-test-final.2026-08-29T16-05.md`). Counts: **3893 passed, 2 failed, 9
skipped, 0 inconclusive, 0 not run**; the passed count rose from 3851 discovered / 3849 passed at
baseline to 3904 discovered / 3893 passed. Form C printed the repository-wide LINE counter and all
three required per-file LINE counters. Post-change repository-wide LINE coverage is **94.7 percent**;
the three in-scope hooks are at **93.8**, **93.8**, and **88.1 percent**. All three are at or above
the 85 percent floor, and the two batch-budget hooks record a **decline of 1.8 percentage points**
against baseline, which is stated rather than rounded away. This is loop iteration **1**.

## Form A — observed process exit code and replayed summary

Observed process exit code: **2**.

Unlike the [P0-T12] baseline run, this run **did** print the replayed line beginning
`Tests Passed: `. That line is quoted verbatim below with its ANSI colour escapes stripped:

```
Tests completed in 126.8s
Tests Passed: 3893, Failed: 2, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 94.21% / 0%. 10,849 analyzed Commands in 88 Files.
```

The five counts it carries:

| Count | Value |
| --- | --- |
| Passed | 3893 |
| Failed | **2** |
| Skipped | 9 |
| Inconclusive | 0 |
| NotRun | 0 |

The failed count is **2, not 0**, so the acceptance condition on this task is not met. The condition
is recorded as unmet rather than reinterpreted.

Discovery lines, verbatim:

```
Starting discovery in 160 files.
Discovery found 3904 tests in 4.45s.
```

The discovery count of 3904 matches the Form B JUnit `tests` attribute exactly, which confirms the
JUnit and coverage files correspond to this run and not to an earlier one.

Note on the `Covered 94.21% / 0%` console line: that figure is Pester's **command (instruction)**
coverage over 10,849 analyzed commands, which is a different measure from the JaCoCo `LINE` counter
this plan gates on. The gate figures are the Form C LINE values derived below. The `/ 0%` second
term is the branch figure, which Pester does not populate for PowerShell.

## Passed-count comparison against the [P0-T12] baseline

| Run | Discovered | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| [P0-T12] baseline | 3851 | 3849 | 2 | not recorded |
| [P7-T5] final | 3904 | 3893 | 2 | 9 |
| Delta | +53 | +44 | **0** | — |

The discovered total rose by 53 and the failure count did not move. The passed count rose by 44; the
remaining 9 of the 53 newly discovered tests are the skipped ones. No test that passed at baseline
fails now.

## Form B — failing test names

Verbatim output:

```
root=Pester tests=3904 failures=2
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

- Total tests: 3904
- Failures: 2
- Both names are **byte-identical** to the pair recorded in the [P0-T12] baseline artifact
  `evidence/baseline/powershell-test-coverage.2026-08-29T16-05.md`.

Owning suites, located by content search:

| # | Failing test | Owning suite |
| --- | --- | --- |
| 1 | `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` |
| 2 | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` |

Neither suite appears in `git diff --name-only main -- tests/`, whose complete output is this
feature's own three suites:

```
tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1
tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1
tests/scripts/claude-hooks/persist-session-id.Tests.ps1
```

The Form B blocked branch was **not** taken: `artifacts/pester/pester-junit.xml` was present after
the failing run and parsed successfully. The Form B command exited 0.

## Form C — coverage extraction

Verbatim output:

```
REPO LINE covered=7384 missed=411
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/persist-session-id.ps1 LINE covered=37 missed=5
```

Form C printed **three** per-file lines, one for each required hook.
`artifacts/pester/powershell-coverage.xml` is present and all three files matched. The Form C
command exited 0.

### Derived percentages

`LINE percent = 100 * covered / (covered + missed)`, recorded to one decimal place. Each value was
computed independently from the covered and missed counts above, not copied from any summary line or
from a prior artifact.

| Scope | LINE covered | LINE missed | Total | LINE percent | Floor 85 met? | Margin above floor |
| --- | --- | --- | --- | --- | --- | --- |
| Repository-wide (report root) | 7384 | 411 | 7795 | **94.7** | yes | +9.7 pp |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 121 | 8 | 129 | **93.8** | yes | **+8.8 pp** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 121 | 8 | 129 | **93.8** | yes | **+8.8 pp** |
| `.claude/hooks/persist-session-id.ps1` | 37 | 5 | 42 | **88.1** | yes | **+3.1 pp** |

Arithmetic shown so each figure is independently checkable:
`100 * 7384 / 7795 = 94.7274` → 94.7;
`100 * 121 / 129 = 93.7984` → 93.8;
`100 * 37 / 42 = 88.0952` → 88.1.

All four percentages are real derived values. None is a placeholder. **Each of the three per-file
percentages is at or above 85**, so that half of the task's acceptance is met.

No branch figure is recorded. Pester emits no branch counter for PowerShell and no PowerShell
branch-coverage gate applies.

## Per-file movement against baseline, stated without rounding away the decline

| File | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp (decline)** |
| `.claude/hooks/enforce-python-batch-budget.ps1` | 95.6 (86/90) | 93.8 (121/129) | **-1.8 pp (decline)** |
| `.claude/hooks/persist-session-id.ps1` | 86.8 (33/38) | 88.1 (37/42) | +1.3 pp |
| Repository-wide | 94.7 (7236/7639) | 94.7 (7384/7795) | +0.0 pp |

The two declines are real and are reported as declines. Their cause is the known carried watch item:
four uncovered lines were added to `enforce-powershell-batch-budget.ps1` — two degenerate-input
guards in the containment helper and the unreadable-session-id-file catch block — and the same shape
of addition applies to the Python-hook sibling. Both files grew from 90 to 129 measured lines while
missed lines grew from 4 to 8. The full delta treatment, including the plan's blocking-finding
language for a negative per-file delta, is in
`evidence/qa-gates/coverage-delta.2026-08-29T16-05.md` ([P7-T12]).

## Acceptance verdict for this task

**NOT MET.** The coverage half of the acceptance is satisfied in full: all four percentages are real
derived values and all three per-file figures clear the 85 percent floor. The test half is not: the
Form A run exited 2 with a failed count of 2 rather than 0. The cause is entirely the two
pre-existing failures classified in
`evidence/qa-gates/powershell-test-final.2026-08-29T16-05.md`. No repair was attempted, because both
suites are outside this feature's scope and repairing them is prohibited.

---

## Iteration 2 — re-run after the [P7-T6] restart

Timestamp: 2026-08-29T22-39

This task was re-run in full at its position in iteration 2, after [P7-T6] rewrote a TypeScript file
in iteration 1 and triggered the [P7-T11] restart. All three commands were re-executed with the same
text. The iteration 1 record above is retained rather than overwritten.

EXIT_CODE: 2

### Form A, iteration 2 — verbatim summary lines

```
Starting discovery in 160 files.
Discovery found 3904 tests in 4.39s.
Tests Passed: 3893, Failed: 2, Skipped: 9, Inconclusive: 0, NotRun: 0
Covered 94.21% / 0%. 10,849 analyzed Commands in 88 Files.
```

The five counts are unchanged from iteration 1: passed 3893, failed **2**, skipped 9, inconclusive
0, not run 0.

### Form B, iteration 2 — verbatim output

```
root=Pester tests=3904 failures=2
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits
```

Identical to iteration 1 and to the [P0-T12] baseline pair.

### Form C, iteration 2 — verbatim output

```
REPO LINE covered=7384 missed=411
.claude/hooks/enforce-powershell-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/enforce-python-batch-budget.ps1 LINE covered=121 missed=8
.claude/hooks/persist-session-id.ps1 LINE covered=37 missed=5
```

Every covered and missed count is identical to iteration 1, so every derived percentage in the tables
above is unchanged and is confirmed by a second independent run: repository-wide **94.7**, the two
batch-budget hooks **93.8** each, and `persist-session-id.ps1` **88.1**.

### Determinism note

Two independent full unscoped runs produced byte-identical counts, byte-identical failing test names,
and byte-identical coverage counters. The PowerShell test and coverage measurements are therefore
deterministic, and the two failures are a stable pre-existing condition rather than a flake.

**Iteration 2 verdict for this task: unchanged. Coverage half MET; test half NOT MET for the same
pre-existing cause.**
