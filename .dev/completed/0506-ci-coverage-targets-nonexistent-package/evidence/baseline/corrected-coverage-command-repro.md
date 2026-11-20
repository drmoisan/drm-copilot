# Phase 0 — Live Measurement of the Corrected Coverage Command (P0-T8)

Timestamp: 2026-08-25T22-01

Task: [P0-T8]
Class: command task — four commands, four required fields each.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

This task is load-bearing for AC-4. It carries **no** `ExpectedExitCode:` row, so no per-file
expectation exists for a later `EXIT_CODE:` row to displace, and the plan therefore imposes no
split on it: all four commands are recorded in this single artifact. Each command carries its
own acceptance condition — a successful exit, a recorded numeric value, or an empty status
output — so no command's outcome depends on being the last `EXIT_CODE:` row in the file.

---

## Command 1 of 4 — the corrected pytest command

Timestamp: 2026-08-25T22-01
Command: `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:

- **Exit code 0.**
- **Summary line, verbatim:** `====================== 4121 passed, 5 skipped in 18.10s =======================`
- **A `TOTAL` row IS present**, at line 613 of the captured output, recorded verbatim:

```text
TOTAL                                                               14953   1102   5492    558    91%
```

- **Statement count: 14953**, which is greater than zero. The corrected command therefore
  collects data, in direct contrast to the defective command recorded by P0-T7, which produced
  no `TOTAL` row and no coverage table at all under an identical test suite.
- Remaining `TOTAL` cells: Miss 1102, Branch 5492, BrPart 558, Cover 91%. As noted in the
  P0-T6 artifact, the terminal `Cover` cell is the combined statements-plus-branches ratio and
  is not either policy metric; the two policy metrics are read from the JSON report by command
  2 below.
- **Skipped count: 5.** Pre-existing declared skips, unrelated to this work item.

**This command writes the tracked repository-root `coverage.xml`.** It did so on this run; see
commands 3 and 4.

## Command 2 of 4 — read the two policy metrics from the JSON report

Timestamp: 2026-08-25T22-01
Command: `poetry run python -c "import json;d=json.load(open('artifacts/python/coverage.json'));print(d['totals']['num_statements'],d['totals']['percent_statements_covered'],d['totals']['percent_branches_covered'])"`
EXIT_CODE: 0

Output Summary: The command printed three values on one line, recorded verbatim:

```text
14953 92.6302414231258 85.21485797523671
```

The three values, in the order printed:

| Position | Key | Value |
| --- | --- | --- |
| 1 | `totals.num_statements` | **14953** — greater than zero |
| 2 | `totals.percent_statements_covered` | **92.6302414231258** — the baseline **line coverage** percentage |
| 3 | `totals.percent_branches_covered` | **85.21485797523671** — the baseline **branch coverage** percentage |

**These are the two baseline policy metrics of record for this work item.** Against the uniform
thresholds in `.claude/rules/quality-tiers.md`, the baseline line coverage of 92.6302414231258%
is above the 85% floor and the baseline branch coverage of 85.21485797523671% is above the 75%
floor. No placeholder value is recorded anywhere in this artifact.

The `-c` string is a single line, per Trap 3.

## Command 3 of 4 — restore the tracked `coverage.xml`

Timestamp: 2026-08-25T22-01
Command: `git checkout -- coverage.xml`
EXIT_CODE: 0
Output Summary: The command produced no output and exited 0. It was run from the resolved repository root after commands 1 and 2.

Immediately before this restore, `git status --porcelain -- coverage.xml` reported ` M coverage.xml`, confirming that command 1 did overwrite the tracked file in place. Unlike the P0-T7 run — whose XML report generation aborted with `No data to report` and therefore never wrote the file — this run produced a real report, so the restore was load-bearing here rather than a no-op.

## Command 4 of 4 — confirm the restore

Timestamp: 2026-08-25T22-01
Command: `git status --porcelain -- coverage.xml`
EXIT_CODE: 0
Output Summary: **The command produced no output.** The tracked `coverage.xml` matches its committed content, so it appears in no working-tree status any Phase 4 scope gate reads and will appear in no committed diff the P6-T2 gate reads.

Every exit code above was captured directly from its command, not through a pipe consumer.

---

## Acceptance

| Condition | Result |
| --- | --- |
| First command exits 0 | PASS — `EXIT_CODE: 0` |
| Its `Output Summary:` carries a `TOTAL` row whose statement count is greater than zero | PASS — statement count 14953 |
| Second command prints three values | PASS — `14953 92.6302414231258 85.21485797523671` |
| First printed value is greater than zero | PASS — 14953 |
| Remaining two are the numeric line and branch percentages | PASS — line 92.6302414231258, branch 85.21485797523671 |
| All three recorded verbatim in the artifact | PASS |
| Restore command exits 0 | PASS — `EXIT_CODE: 0` |
| `git status --porcelain -- coverage.xml` produces no output | PASS — no output |

Verdict: PASS. `coverage.xml` is clean.
