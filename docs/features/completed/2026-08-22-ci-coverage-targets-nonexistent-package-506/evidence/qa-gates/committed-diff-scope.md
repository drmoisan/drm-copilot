# Phase 6 — Committed-Diff Scope Gate (P6-T2)

Timestamp: 2026-08-25T22-44

Task: [P6-T2]
Class: **command task.** Records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`,
once per command executed.

Working directory: the resolved repository root
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by
[P0-T2]).

This artifact is the **falsifiable form of AC-14 and AC-15**. Before [P6-T1] the branch head was
the merge base that the three-dot form diffs against, so a committed-diff listing was necessarily
empty and could not fail, regardless of where `origin/main` had moved. Only after that commit does
the diff carry the change, which is why the committed form of the two exclusions is asserted here
rather than in Phase 5.

---

## [P6-T1] commit record, consolidated here per the plan's carve-out

[P6-T1] names no artifact of its own; its state is consolidated into this artifact, which cannot
record a non-empty committed diff unless that commit succeeded.

| Value | SHA |
| --- | --- |
| Pre-commit `git rev-parse HEAD` | `05a184be4503a23f5527f55dc89f0154e37ad740` |
| Post-commit `git rev-parse HEAD` | `08c9c14f6b1e93def5177a10910a12c4c12fee87` |
| Commit SHA produced by [P6-T1] | `08c9c14f6b1e93def5177a10910a12c4c12fee87` |

[P6-T1] acceptance, all three conditions required:

| Condition | Result |
| --- | --- |
| **(a)** The commit command exits 0 | **PASS** — `git commit` reported `4 files changed, 264 insertions(+), 18 deletions(-)` |
| **(b)** The post-commit HEAD differs from the pre-commit HEAD | **PASS** — `05a184be...` differs from `08c9c14f...`, proving a commit was actually created |
| **(c)** `git status --porcelain` exits 0 and produces no output | **PASS** — no output |

Condition (b) is the only condition that proves the commit happened, and it is phrased as this
own-before-and-after comparison deliberately: a clean-tree assertion is by construction satisfied
by emptiness, and a comparison against `origin/main` cannot serve as the proof either, because the
remote-tracking ref may already have advanced past the branch point.

The four paths committed by [P6-T1] were `plan.2026-08-23T23-21.md` (modified),
`spec.md` (modified), `evidence/other/ac-evidence-index.md` (new), and
`evidence/other/human-interaction-d5.md` (new). `coverage.xml` did **not** appear as modified, so
the restores required by [P0-T7], [P0-T8], and [P4-T5] all held.

---

## Command

Command: `git diff --name-only origin/main...HEAD`
EXIT_CODE: 0
Output Summary: the command printed **42** paths. The three-dot form against `origin/main` is
required because the local `main` ref may be stale. Per Trap 4 this command emits a bare name list
with no status field and no arrow form, so only the unquoting step of that trap applies; no path in
the output was quoted, so no unquoting was necessary and the printed lines are the recorded name
list verbatim.

---

## Full recorded name list (42 paths)

```text
.github/workflows/_quality-checks.yml
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-repro.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-restore.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-environment-provenance.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-format-black.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-lint-ruff.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-test-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-typecheck-pyright.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/workflow-actionlint.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/ac-evidence-index.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/batch-budget-clear-before-toolchain-restart.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/human-interaction-d5.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-28.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-45.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T12-55.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-05.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-21.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-delta.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-threshold-enforcement.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-format-black.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-lint-ruff.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-test-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-typecheck-pyright.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/toolchain-single-pass-transcript.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-actionlint-post-edit.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/worktree-scope-blocked-policy-files.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/worktree-scope-pyproject.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/checker-unit-tests-pass.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-fail-before.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-pass-after.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md
scripts/dev_tools/check_python_coverage_thresholds.py
tests/scripts/dev_tools/test_check_python_coverage_thresholds.py
tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
```

---

## Condition (a) — the recorded name list is non-empty and contains the four required paths

| Required path | Present |
| --- | --- |
| `.github/workflows/_quality-checks.yml` | **yes** |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | **yes** |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | **yes** |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | **yes** |

The list holds 42 paths, so it is non-empty, and all four required paths are present.

Verdict for condition (a): **PASS.**

---

## Condition (b) — `pyproject.toml` is absent, satisfying AC-14

`pyproject.toml` does not appear anywhere in the 42-path list. No path in the list is the project
manifest at the repository root, and no path in the list ends in `pyproject.toml`. The manifest's
configured coverage source list was already correct and its omit list was already compliant with
the Coverage Exclusion Policy, so no task in this plan modified it.

Verdict for condition (b): **PASS.**

---

## Condition (c) — none of the four blocked policy paths appears, satisfying AC-15

| Blocked policy path | Present in the recorded name list |
| --- | --- |
| `.github/instructions/python-unit-test.instructions.md` | **absent** |
| `.github/instructions/python-suppressions.instructions.md` | **absent** |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | **absent** |
| `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | **absent** |

No path in the list begins with `.github/instructions/` and no path begins with
`extensions/`. The only `.github/` path in the list is the workflow file itself. The unresolved
decision covering these four paths is recorded at
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/human-interaction-d5.md`.

Verdict for condition (c): **PASS.**

---

## Condition (d) — every path falls under one of the nine write-set entries

| Write-set entry | Entry description | Paths matched |
| --- | --- | --- |
| 1 | `.github/workflows/_quality-checks.yml` — modified | 1 |
| 2 | `scripts/dev_tools/check_python_coverage_thresholds.py` — new production module | 1 |
| 3 | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` — new test | 1 |
| 4 | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` — new test | 1 |
| 5 | the plan file | 1 |
| 6 | `spec.md` — acceptance-criteria check-off only | 1 |
| 7 | the entire `evidence/` subtree | 34 |
| 8 | `issue.md` — committed unmodified | 1 |
| 9 | the research document — committed unmodified | 1 |
| | **Total** | **42** |

Every one of the 42 paths is accounted for, and 42 equals the number of paths the command printed,
so no path in the list falls outside the closed write set.

Entries 8 and 9 are expected to appear here because the entire feature folder is untracked at
`origin/main`, so the issue document and the research document are committed by [P6-T1] even though
no task in this plan edits either.

The 34 paths matched by entry 7 break down as 10 under `evidence/baseline/`, 8 under
`evidence/other/`, 13 under `evidence/qa-gates/`, and 3 under `evidence/regression-testing/`. The 8
under `evidence/other/` include **five** preflight-findings artifacts written by the preflight
validation cycles that ran before execution began, plus one batch-budget record and the two Phase 5
artifacts. Entry 7 is stated as the whole evidence subtree, and the plan states explicitly that the
preflight-findings artifacts are an **open enumeration, not a closed set, and no task may treat
them as a count**; five such artifacts rather than the four the plan's illustrative list names is
therefore inside the write set, not a finding.

`coverage.xml` is **not** among the 42 paths. The tracked repository-root `coverage.xml` is
transiently overwritten by the three tasks that pass `--cov-report=xml` ([P0-T7], [P0-T8], and
[P4-T5]) and is restored by each of them, so it appears in no committed diff.

Verdict for condition (d): **PASS.**

---

## Acceptance for [P6-T2]

| Condition | Verdict |
| --- | --- |
| **(a)** Recorded name list non-empty and contains the four required paths | **PASS** |
| **(b)** Recorded name list does not contain `pyproject.toml` — AC-14 | **PASS** |
| **(c)** Recorded name list contains none of the four blocked policy paths — AC-15 | **PASS** |
| **(d)** Every path falls under one of the nine write-set entries, and `coverage.xml` is not among them | **PASS** |

No condition failed, so the phase does not halt. [P6-T7] reads the conditions (b), (c), and (d)
verdicts above.

Verdict: **PASS.**
