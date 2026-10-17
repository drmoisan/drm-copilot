# Feature Audit: Issue #890 (parallel skills Python engine calls and enum error members)

- Timestamp: 2026-10-12T20-40
- Branch: `bug/parallel-skills-python-engine-calls-and-enum-error-members-890`
- Head: 05d4cc0d5; diff base `origin/main...HEAD`
- Overall verdict: **CONDITIONAL** (CI-pending items only)
- Blocking findings: 0

## Scope and Baseline

- Base: `origin/main`; diff `git diff origin/main...HEAD` (94 files; 34 outside the feature folder).
- Work mode: `minor-audit`. Sole AC source: `issue.md`, section `## Acceptance Criteria` (AC-1..AC-7). `spec.md` and `user-story.md` are not AC sources in this mode.
- Baseline evidence: `engine-name-baseline-890.md` (22 engine-name hits in the three skills before the change); Python coverage baseline 34/34 lines (`coverage-delta-890.md`).
- Reviewer verification performed: read the diff, ran Grep for residual engine names, compared mirrors with `cmp`, read the bash library against the Python reference, parsed `artifacts/python/lcov.info`, ran `validate_evidence_locations.py`, and re-read diff hunk ranges for the overlap zones.
- Not performed by the reviewer: bats execution and kcov (forbidden locally by the operator's Option A constraint; they run in PR CI).

## Acceptance Criteria Inventory

| AC | Summary |
|---|---|
| AC-1 | No Python engine call remains in the three skills; each former call site names `mutate-parallel-run.sh` or `remove-parallel-item.sh` |
| AC-2 | New bash entry points exist, are mirrored, listed in `core.json`, within 500 lines, and covered by bats suites sharing the parity corpus with the Python lane |
| AC-3 | `poetry run python -c` grant removed from the persona with a decision record; new `mutate-parallel-run.sh` grant |
| AC-4 | `UnknownEnumMemberError` lists the members of the rejected field; per-field tests; docstrings and divergence comments updated |
| AC-5 | Operator-accepted residual risks (a) and (b) carried unchanged |
| AC-6 | Toolchain and coverage gates: Python clean with changed module meeting thresholds; bash kcov via PR CI; no PowerShell change |
| AC-7 | Overlap zones for #885 and #899 untouched |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-1 | PASS | Zero hits for `parallel_mutation_protocol`, `decide_admission`, `recolor_unstarted`, `build_add_entry`, `decide_close`, `build_close_entry`, `build_requeue_entry` in the three skills (reviewer Grep, no matches) and mirrors (byte-identical per `cmp`); baseline had 22 hits (`engine-name-baseline-890.md`, `engine-name-final-890.md`). Each former call site names `mutate-parallel-run.sh` or `remove-parallel-item.sh`. `test_mutation_skills_invoke_bundled_mutation_script` passes for all three skills. Already checked. |
| AC-2 | PARTIAL, pending-CI | Local part holds: entry points `mutate-parallel-run.sh`, `parallel-mutation-cli.sh`, `parallel-mutation-ops.sh` exist; mirrors byte-identical; listed in `core.json`; every new or edited file is at or under 500 lines (max 481); bats suites `parallel_mutation_run.bats` and `parallel_mutation_run_parity.bats` exist; the parity corpus is shared (21 fixtures) with the Python lane (`test_parallel_mutation_run_bash_parity.py`, 25 passed). Remaining: the bats suites have not executed (Option A). Left unchecked. |
| AC-3 | PASS | Grant removed from persona and mirror; decision record `evidence/other/python-c-grant-decision-890.md` with dependency evidence; new grant for `mutate-parallel-run.sh`; `test_parallel_orchestrator_permission_contracts.py` passed within the 102-test surface run. Already checked. |
| AC-4 | PASS | One unit test per field (`state`, `merge_status`, `disposition`) plus the real raise site and the unmapped-field case; docstrings rewritten (grep for the old phrase reports 0); bash `pm_decide_removal` message aligned with a new bats case; divergence comments carry R1 wording and `_parallel_mutation_errors.py:192` no longer appears (`divergence-token-final-890.md`). Already checked. |
| AC-5 | PASS | `issue.md` `## Operator-Accepted Residual Risks` holds risks (a) and (b) with acceptance status unchanged; `pr-body-carry-forward-890.md` prepared. Already checked. |
| AC-6 | PARTIAL, pending-CI | Local part holds: Black, Ruff, Pyright clean; pytest 129 passed; changed module `_parallel_mutation_errors.py` line 37/37 = 100%, branch 2/2 = 100% (thresholds 85 / 75; `coverage-delta-890.md`); no changed PowerShell file (`scope-check-890.md`). Remaining: the PR CI `shell-coverage / Shell Coverage (Bats + kcov)` job. Left unchecked. |
| AC-7 | PASS | Hunk ranges avoid parallel-add lines 53-74 (step 2 plus #885 adoption block) and parallel-orchestrate lines 371-385 (#899 passage) (`overlap-zones-890.md`; reviewer re-read of the diff hunks confirms no edit before parallel-add line 105 and none before parallel-orchestrate line 662). Already checked. |

### What CI Must Show (to close AC-2 and AC-6)

1. The job whose name is `shell-coverage / Shell Coverage (Bats + kcov)` on the pushed head concludes `success`, with these bats suites included and passing: `parallel_mutation_run.bats`, `parallel_mutation_run_parity.bats`, `parallel_mutation_remove.bats`, `parallel_mutation_remove_parity.bats`, `parallel_payload_only.bats`, `parallel_bash_manifest_membership.bats`.
2. The log reports `Bash coverage (lines): NN.N%` at or above 85.
3. The kcov Cobertura report (`cov.xml` from the `shell-coverage` artifact) shows per-file line rates at or above 85% for `.claude/lib/bash/mutate-parallel-run.sh`, `parallel-mutation-cli.sh`, `parallel-mutation-ops.sh`, and, as edited files with no regression, `parallel-mutation.sh` and `remove-parallel-item.sh`. kcov discovery covers `.claude/lib/bash/` per `.claude/rules/shell.md`.
4. `shell-qc.sh check` (shfmt 3.8.0 pin, apt shellcheck) is clean; the local pre-check used shfmt 3.12.0 and ShellCheck 0.11.0.
5. The main `ci.yml` Python jobs are green, which supplies the repo-wide Python coverage figure that is not derivable from the module-scoped local artifact.

If CI reports a bats failure, the likeliest locations are the per-fixture replay in `parallel_mutation_run_parity.bats` (it is the only suite built on `mapfile -d` with a Python-read argv) and the default-`--at` cases in `parallel_mutation_run.bats`, since neither could be exercised locally.

## Summary

Five of seven acceptance criteria (AC-1, AC-3, AC-4, AC-5, AC-7) are PASS. AC-2 and AC-6 are PARTIAL and depend solely on PR CI evidence (bats execution and kcov line rates); their local parts hold. The overall verdict is **CONDITIONAL** with CI-pending items only. No blocking finding; no remediation-inputs artifact is produced. Plan tasks P2-T14 and P2-T15 remain open by design, and Evidence Checklist `end-state` remains unchecked until they complete.

## Acceptance Criteria Check-off

AC-1, AC-3, AC-4, AC-5, and AC-7 were already checked (`- [x]`) in `issue.md`; the reviewer verified each as PASS and made no edit to `issue.md`. AC-2 and AC-6 are evaluated PARTIAL and are left unchecked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-10-11-parallel-skills-python-engine-calls-and-enum-error-members-890/issue.md` (`## Acceptance Criteria`)
- Total AC items: 7
- Checked off (delivered): 5 (AC-1, AC-3, AC-4, AC-5, AC-7); verified by this review, none newly checked
- Remaining (unchecked): 2
- Items remaining: AC-2 (bats execution and parity run in CI), AC-6 (`shell-coverage` job and per-file kcov line rates)
