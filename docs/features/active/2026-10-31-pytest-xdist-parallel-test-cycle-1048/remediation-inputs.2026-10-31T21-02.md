# Remediation Inputs (Issue #1048), feature review 2026-10-31T21-02

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

**Entry timestamp:** 2026-10-31T21-02
**Feature folder:** `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048`
**Base branch:** `main` (merge base `58b81ca577943cd2944b62ee23ff3a3d1d737092`)
**Head reviewed:** `d817f4075c4c9f5a69b185173e53987ae8d0dd91` on `feature/pytest-xdist-parallel-test-cycle-1048`
**Work mode:** `full-feature`; AC sources are `spec.md` and `user-story.md` `## Acceptance Criteria` (33 of 44 met; 2 PARTIAL; 9 pending CI)
**Finding count:** 4 (autonomous: 1; awaiting_ci: 3)
**Audit artifacts:**
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/policy-audit.2026-10-31T21-02.md`
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/code-review.2026-10-31T21-02.md`
- `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/feature-audit.2026-10-31T21-02.md`

## Findings

### F1 (CR-1, deviation D1) - tasks.json criteria require a validation that cannot run on a JSONC file

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a wording correction to two criteria in this item's own spec, backed by evidence already in the feature folder; no external system, owner decision, or CI run is needed.

File: `docs/features/active/2026-10-31-pytest-xdist-parallel-test-cycle-1048/spec.md`, `## Acceptance Criteria`: the Part 1 item beginning "`.vscode/tasks.json` contains a parallel unit-test task" and the Part 2 item beginning "A VS Code task runs `Invoke-PoshQCParallelTest`".

Current state: both items end with "passes governed-JSON validation". `scripts/dev_tools/json_config.py` `GOVERNED_GLOBS` covers `scripts/**/*.json`, `docs/**/*.json`, and `examples/**/*.json` only and notes that `.vscode` files are JSONC. `poetry run python -m scripts.dev_tools.validate_json .vscode/tasks.json` exits 1 with `invalid JSON (Expecting value: line 1 column 1 (char 0))` at `HEAD`, and gives the same message for the merge-base copy of the file. The clause therefore cannot be met by any version of `tasks.json`.

Determination: AC wording defect (not a genuine gap: the three tasks are delivered and parse; not a policy hold: no policy requires `tasks.json` to be governed).

Fix:
1. In each of the two items, replace only the clause "passes governed-JSON validation" with wording of this form: "parses as JSONC (full-line comments removed) with every required label present; the file is outside the governed-JSON globs, so `validate_json` does not apply (evidence: `evidence/other/validate-json-tasks.2026-10-31T18-16.md`)". Keep the rest of each criterion unchanged and add no new criterion.
2. Record the amendment and the reason in a feature-folder evidence file under `evidence/other/` (command, exit code, the JSONC parse result, and the five labels: `QC: 4 Pytest: run tests`, `QC: 4 Pytest: run tests (parallel)`, `QC: 4 Pytest: run tests with coverage (parallel)`, `PoshQC: 4 test (Pester)`, `PoshQC: 4 test (Pester, parallel)`).
3. Check off both items in `spec.md` after the verification passes. Update the P1-T5 and P6-T3 acceptance notes in the plan only if the plan is revised in this cycle; the deviation record D1 already explains them.

Verification:
- JSONC parse of `.vscode/tasks.json` succeeds (55 tasks) and the five labels are present.
- `spec.md` diff shows only the two clause replacements and the two checkbox changes.

### A1 - pytest worker setting and CI timings (P9-T1, P9-T2, P9-T3)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The criteria need the duration of `quality-checks7 / Code Quality & Tests (3.13)` and the xdist worker count from CI runs on the branch head with `-n auto` and with `-n 4`; no such run exists yet, and orchestrator step 9 owns them.

Criteria: `spec.md` S2 (CI step faster setting, threshold on merged coverage) and S9 (both CI timings, before and after duration); `user-story.md` U2 and U5. Do not check them off before the step 9 records exist.

### A2 - CI Pester shard spread after the weights change (P9-T4)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The spread comparison needs the three shard durations of a branch-head CI run against the recorded baseline run; only a projection exists locally, and orchestrator step 9 owns the measurement and any shard-count decision.

Criteria: `spec.md` S21; `user-story.md` U8. When the spread is not smaller and a fourth shard is chosen, the `_poshqc.yml` matrix, `## CI Shape and Required Checks` in all six brief copies, and `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` change together through a remediation cycle.

### A3 - Green branch-head run, lock-sync step, and Linux hook-suite observation (P9-T5)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The modified workflow requires a green full CI run on the final head (`modified-workflow-needs-green-run`), and the lock-sync step, `_poshqc.yml` merged coverage and completeness, the Python 3.10 to 3.13 matrix under the new strict pytest options, and the ruleset read are all results of that run; orchestrator step 9 owns them.

Criteria: `spec.md` S1 (lock-sync CI step clause), S24, S29; Definition of Done item "Behavior matches acceptance criteria in all documented environments".

## Related non-blocking findings (planner discretion, same files)

These are not counted above. Under the operator preference that related findings are fixed inside the item before merge, the planner may include CR-2 in this cycle.

- CR-2 (Minor): `Invoke-PoshQCParallelTest` resolves an omitted `-Root` to the current location and a relative `-Root` against it (JaCoCo lines 408 and 411 unexecuted). Add two cases to `tests/scripts/powershell/PoshQC/PoshQC.ParallelRunner.Tests.ps1` that assert the resolved root in the captured shard argument list, using the existing seams (no process, no file, no temp path; set the location through a mocked or injected value rather than changing the process directory if the module allows it, otherwise restore it in `AfterEach`). Mirror nothing (test-only). Re-run the PoshQC suites, the shuffled seeds, and the full Pester run with coverage; `PoshQC.Parallel.psm1` line coverage must not fall below 96.00%.
- CR-3 (Info): orphaned children when a shard fails to start; optional.

## Do not do

- Do not add a coverage exclusion for `PoshQC.Parallel.psm1` or any production file; the uncovered `Invoke-PoshQCPwshExe` lines are accepted as they are.
- Do not add `.vscode/` to the governed-JSON globs or change `scripts/dev_tools/json_config.py` to satisfy F1.
- Do not check off any criterion that depends on CI (S1, S2, S9, S21, S24, S29, U2, U5, U8) in the remediation cycle.
- Do not add `-n` to `addopts`, add `psutil`, add a new Python script, or modify any file under `.claude/hooks/`, `.codex/hooks/`, `.claude/rules/`, or `.github/instructions/`.
- Write evidence only under `<FEATURE>/evidence/<kind>/`.
