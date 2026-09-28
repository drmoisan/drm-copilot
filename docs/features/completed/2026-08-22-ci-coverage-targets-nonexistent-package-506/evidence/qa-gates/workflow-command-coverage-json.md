# Phase 4 — The Workflow's Corrected Command and the Two Policy Metrics (P4-T5)

Timestamp: 2026-08-25T22-31

Task: [P4-T5]
Class: command task — four commands, four required fields each.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

This task runs the workflow's own corrected command form — the exact command the edited
`.github/workflows/_quality-checks.yml` pytest step now carries — and reads the two policy metrics
from the JSON report it emits. This artifact is load-bearing for AC-19 and supplies the
post-change pair used by the P4-T12 coverage delta record.

This task carries **no** `ExpectedExitCode:` row, so no per-file expectation exists for a later
`EXIT_CODE:` row to displace, and the plan therefore imposes no split on it: all four commands are
recorded in this single artifact. Each command carries its own acceptance condition — a successful
exit, a recorded numeric value, or an empty status output — so no command's outcome depends on
being the last `EXIT_CODE:` row in the file.

---

## Command 1 of 4 — the workflow's corrected pytest command

Timestamp: 2026-08-25T22-31
Command: `poetry run pytest --cov --cov-branch --cov-report=xml --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:

- **Exit code 0**, captured directly from the command with no pipe consumer between the command
  and the status.
- **Summary line, verbatim:**

```text
====================== 4136 passed, 5 skipped in 21.40s =======================
```

- **A `TOTAL` row IS present**, recorded verbatim:

```text
TOTAL                                                               15014   1104   5506    560    91%
```

- **Statement count: 15014**, which is greater than zero. The corrected command collects data, in
  direct contrast to the defective committed command recorded by P0-T7, which produced no `TOTAL`
  row and no coverage table at all under an identical test suite.
- Remaining `TOTAL` cells: Miss 1104, Branch 5506, BrPart 560, Cover 91%. **The terminal `Cover`
  cell is the combined statements-plus-branches ratio and is neither policy metric**; its `BrPart`
  cell is the partial-branch count and not the missing-branch count. The two policy metrics are
  read from the JSON report by command 2 below.
- **This command writes the tracked repository-root `coverage.xml`.** It did so on this run; see
  commands 3 and 4.

## Command 2 of 4 — read the two policy metrics from the JSON report

Timestamp: 2026-08-25T22-31
Command: `poetry run python -c "import json;d=json.load(open('artifacts/python/coverage.json'));print(d['totals']['num_statements'],d['totals']['percent_statements_covered'],d['totals']['percent_branches_covered'])"`
EXIT_CODE: 0

Output Summary: The command printed three values on one line, recorded verbatim:

```text
15014 92.64686292793392 85.2161278605158
```

The three values, in the order printed:

| Position | Key | Value | Floor | Result |
| --- | --- | --- | --- | --- |
| 1 | `totals.num_statements` | **15014** | > 0 | greater than zero |
| 2 | `totals.percent_statements_covered` | **92.64686292793392** — the post-change **line coverage** percentage | 85 | at or above the floor |
| 3 | `totals.percent_branches_covered` | **85.2161278605158** — the post-change **branch coverage** percentage | 75 | at or above the floor |

**These are the two post-change policy metrics of record for this work item.** Against the uniform
thresholds in `.claude/rules/quality-tiers.md`, the post-change line coverage of
92.64686292793392% is above the 85% floor and the post-change branch coverage of
85.2161278605158% is above the 75% floor. No placeholder value is recorded anywhere in this
artifact.

The `-c` string is a single line, per Trap 3.

## Command 3 of 4 — restore the tracked `coverage.xml`

Timestamp: 2026-08-25T22-31
Command: `git checkout -- coverage.xml`
EXIT_CODE: 0
Output Summary: The command produced no output and exited 0. It was run from the resolved
repository root immediately after commands 1 and 2.

Immediately before this restore, `git status --porcelain -- coverage.xml` reported ` M coverage.xml`,
confirming that command 1 did overwrite the tracked file in place. The restore was therefore
load-bearing on this run rather than a no-op.

## Command 4 of 4 — confirm the restore

Timestamp: 2026-08-25T22-31
Command: `git status --porcelain -- coverage.xml`
EXIT_CODE: 0
Output Summary: **The command produced no output.** The tracked `coverage.xml` matches its
committed content, so it appears in no working-tree status the P4-T11 write-set gate reads, in no
working-tree status the P6-T1 clean-tree gate reads, and in no committed diff the P6-T2 gate
reads.

Every exit code above was captured directly from its command, not through a pipe consumer.

---

## Acceptance

| Condition | Result |
| --- | --- |
| The artifact records a statement count greater than zero | PASS — 15014 |
| A numeric line percentage at or above 85 | PASS — 92.64686292793392 |
| A numeric branch percentage at or above 75 | PASS — 85.2161278605158 |
| AC-19 satisfied | PASS — both policy metrics measured above their floors by the workflow's own command form |
| The restore command exits 0 | PASS — `EXIT_CODE: 0` |
| `git status --porcelain -- coverage.xml` produces no output | PASS — no output |
| No placeholder value recorded | PASS |

Verdict: PASS.
