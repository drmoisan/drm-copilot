# Phase 0 — Live Reproduction of the Defective Coverage Command (P0-T7)

Timestamp: 2026-08-25T22-00

Task: [P0-T7]
Class: command task — this artifact records the **pytest command only** and carries exactly one `EXIT_CODE:` row.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

The restore command and its status confirmation are recorded in the sibling artifact
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-restore.md`.
The split is mandatory and follows the per-file expectation rule in
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`: the expectation field is per-file,
not per-command, so a restore row recorded after the pytest row would be the row the per-file
expectation is tested against.

## Command

Command: `poetry run pytest --cov=src/lexile_corpus_tuner --cov-report=xml --cov-report=term-missing`
EXIT_CODE: 0
ExpectedExitCode: 0

The `ExpectedExitCode:` value equals the exit code the pytest command actually produced. It
records that this command is deliberately defective and that its exit code is **not** this
task's verdict, so a reader does not mistake the row for a failed task. The defect is silent:
the coverage target names a package that does not exist in this repository, so `coverage.py`
collects no data at all and yet pytest still exits 0 because every test passed. That silence is
precisely the defect this work item exists to repair.

Output Summary:

- **The exit code is NOT this task's verdict.** The verdict is the absence of a `TOTAL` row
  combined with a recorded passed count greater than zero. The command is deliberately
  defective and was run verbatim as committed in `.github/workflows/_quality-checks.yml`.
- **Collected line, verbatim:** `collected 4126 items`
- **Summary line, verbatim:** `======================= 4121 passed, 5 skipped in 9.80s =======================`
- **Passed count: 4121.** Greater than zero, so the run genuinely executed the suite and the
  absent coverage table is not an artefact of an aborted collection.
- **Skipped count: 5.** Pre-existing declared skips, unrelated to this work item.
- **A `TOTAL` row was NOT printed.** Confirmed by a fixed-anchor search of the captured output
  for a line beginning `TOTAL`: **0 occurrences**.
- **The coverage table has no rows.** Confirmed by a fixed-anchor search for the table header
  line beginning `Name` and containing `Stmts`: **0 occurrences**. The `tests coverage` section
  header is printed and is immediately followed by the platform line and then by the short test
  summary, with no table between them.

Verbatim diagnostic block emitted by `coverage.py` and `pytest-cov`, which names the cause
directly:

```text
C:\Users\DanMoisan\repos\drm-copilot\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module src/lexile_corpus_tuner was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
C:\Users\DanMoisan\repos\drm-copilot\.venv\Lib\site-packages\coverage\control.py:958: CoverageWarning: No data was collected. (no-data-collected); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-no-data-collected
  self._warn("No data was collected.", slug="no-data-collected")
C:\Users\DanMoisan\repos\drm-copilot\.venv\Lib\site-packages\pytest_cov\plugin.py:363: CovReportWarning: Failed to generate report: No data to report.

  warnings.warn(CovReportWarning(message), stacklevel=1)

WARNING: Failed to generate report: No data to report.
```

Verbatim empty coverage section, showing the section header with no table beneath it:

```text
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

=========================== short test summary info ===========================
```

The exit code was captured directly from the command, not through a pipe consumer.

## `coverage.xml` handling

The plan records that this command passes `--cov-report=xml` and therefore writes the tracked
repository-root `coverage.xml`. On this run the report generation **failed before writing**
(`Failed to generate report: No data to report.`), so the tracked file was in fact never
overwritten: `git status --porcelain -- coverage.xml` produced no output immediately after the
pytest run, before any restore was attempted.

The restore was nonetheless executed unconditionally as the plan directs, because the mandated
sequence must not depend on an observation of whether the write happened. Its command, exit
code, and status confirmation are recorded in the restore artifact named above.

## Acceptance

| Condition | Result |
| --- | --- |
| Both artifacts exist (repro and restore) | PASS — the restore artifact is present at the sibling path named above |
| Repro artifact records the pytest exit code | PASS — `EXIT_CODE: 0` |
| Repro artifact records verbatim the summary line reporting collected and passed counts | PASS — collected 4126, `4121 passed, 5 skipped in 9.80s` |
| Repro artifact states explicitly whether a `TOTAL` row was printed | PASS — explicitly stated: no `TOTAL` row was printed |
| Recorded passed count is greater than zero | PASS — 4121 > 0 |
| No `TOTAL` row present | PASS — 0 occurrences |
| Coverage table has no rows | PASS — 0 header rows |
| Exactly one `EXIT_CODE:` row in this artifact | PASS |

**Reproduction CONFIRMED.** The passed count is greater than zero, no `TOTAL` row is present,
and the coverage table has no rows. No populated `TOTAL` row appeared, so the root-cause
analysis is not contradicted. The verdict is not BLOCKED.
