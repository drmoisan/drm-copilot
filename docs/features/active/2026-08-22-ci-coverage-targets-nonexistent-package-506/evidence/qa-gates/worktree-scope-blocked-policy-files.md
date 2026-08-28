# Phase 4 — Scope Gates: Blocked Policy Files (P4-T10) and Closed Write Set (P4-T11)

Timestamp: 2026-08-25T22-33

Tasks: [P4-T10] and [P4-T11]
Class: **record-only tasks.** Per the plan's evidence accounting rule, P4-T10 and P4-T11 are
record-only: both are directed by their task text to use "the same command output captured in
P4-T9" and neither executes a command of its own. This artifact therefore records `Timestamp:` and
the substantive content the two tasks prescribe, and carries **no** `Command:` row and **no**
`EXIT_CODE:` row.

Source of the path lists below, cited so both commands and their exit codes remain auditable one
hop away:

- Task that executed them: **[P4-T9]**
- Artifact recording them with all four required fields:
  `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/worktree-scope-pyproject.md`
- The two commands, both run from the resolved repository root and both recorded there with
  `EXIT_CODE: 0`: `git status --porcelain --untracked-files=all` and
  `git diff --name-only origin/main...HEAD`.

Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

---

## Declared substitution: both gates are evaluated against a UNION of two lists, which is strictly stronger than the plan's form

The full statement of the substitution, with its reason, is recorded in the P4-T9 artifact cited
above and applies identically here. In summary:

The plan's Phase 4 preamble assumes the branch carries no commit of its own at this point, and on
that premise directs the three Phase 4 scope gates to read the **working tree** and to assert a
non-empty derived path list. **That premise no longer holds in this execution:** for resilience
against abrupt termination this orchestration commits after each phase, so Phases 0 through 3 are
already committed as `49b12171`, `ed5f2ca4`, and `6f8633c8` and have been pushed. The Phase 1
through Phase 3 edits are therefore not pending in the working tree, and the plan's non-empty
condition (a) would fail against a working-tree-only list for a reason that is not a defect.

Accordingly:

1. `git status --porcelain --untracked-files=all` was still run and its raw output and
   Trap-4-derived path list are recorded in full (in the P4-T9 artifact, and reproduced below).
2. `git diff --name-only origin/main...HEAD` was **additionally** run and its name list is recorded
   in full under its own clearly labelled heading below.
3. Condition **(a)** of each gate is evaluated against the **union** of the two lists.
4. Condition **(b)** of each gate is evaluated against the union as well, and must hold for **both**
   lists independently — an exclusion is not permitted to pass merely because the excluded path is
   absent from one list.

The gate is therefore **strengthened rather than bypassed**. The union is non-empty and contains
real evidence, so both conditions remain falsifiable, and for condition (b) the union is strictly
stronger than the working tree alone: a committed edit to a blocked policy file, or to any path
outside the closed write set, would be invisible to a working-tree-only read and is visible here.

P6-T2 re-runs the committed-diff form after the Phase 5 commit; this substitution does not replace
that task.

---

## List 1 — the working-tree derived path list

Derived by applying all three Trap 4 steps to the raw output of
`git status --porcelain --untracked-files=all`, as recorded by P4-T9: the three-character status
field was stripped from every line; no line carried the arrow form `old -> new`, so zero renames
were expanded; and no line's path was wrapped in double quotes, so zero C-style unquotings were
required.

Ten entries:

1. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md`
2. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/batch-budget-clear-before-toolchain-restart.md`
3. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-threshold-enforcement.md`
4. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-format-black.md`
5. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-lint-ruff.md`
6. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-test-coverage.md`
7. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-typecheck-pyright.md`
8. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md`
9. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/toolchain-single-pass-transcript.md`
10. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md`

## List 2 — the committed name list (the declared substitution)

From `git diff --name-only origin/main...HEAD`. Per Trap 4 this command emits a bare name list, so
only the unquoting step applies; no entry is wrapped in double quotes, so that step produced no
change. Twenty-eight entries:

1. `.github/workflows/_quality-checks.yml`
2. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md`
3. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-repro.md`
4. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/defective-coverage-command-restore.md`
5. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/phase0-instructions-read.md`
6. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-environment-provenance.md`
7. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-format-black.md`
8. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-lint-ruff.md`
9. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-test-coverage.md`
10. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/python-typecheck-pyright.md`
11. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/workflow-actionlint.md`
12. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-28.md`
13. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-45.md`
14. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T12-55.md`
15. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-05.md`
16. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-21.md`
17. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md`
18. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-actionlint-post-edit.md`
19. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/checker-unit-tests-pass.md`
20. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-fail-before.md`
21. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/regression-testing/workflow-contract-tests-pass-after.md`
22. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/issue.md`
23. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md`
24. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/research/2026-08-23T23-45-ci-coverage-target-remedy-research.md`
25. `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/spec.md`
26. `scripts/dev_tools/check_python_coverage_thresholds.py`
27. `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py`
28. `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py`

## The union

The plan file (`plan.2026-08-23T23-21.md`) is the only path appearing in both lists, so the union
holds **37 distinct paths**: the 28 committed names plus the 9 working-tree-only evidence
artifacts.

---

# [P4-T10] — the four blocked policy paths are absent

## Present-or-absent statement for each blocked path

`CLAUDE.md` forbids modifying files under `.github/instructions`. The plan's Write set section
declares four paths **blocked, must not be written**: the two Python instruction documents and
their two bundled mirrors. Each is checked against **both** lists independently.

| # | Blocked path | In working-tree list? | In committed name list? | In union? |
| --- | --- | --- | --- | --- |
| 1 | `.github/instructions/python-unit-test.instructions.md` | **ABSENT** | **ABSENT** | **ABSENT** |
| 2 | `.github/instructions/python-suppressions.instructions.md` | **ABSENT** | **ABSENT** | **ABSENT** |
| 3 | `extensions/drm-copilot/resources/customizations/.github/instructions/python-unit-test.instructions.md` | **ABSENT** | **ABSENT** | **ABSENT** |
| 4 | `extensions/drm-copilot/resources/customizations/.github/instructions/python-suppressions.instructions.md` | **ABSENT** | **ABSENT** | **ABSENT** |

All four are absent from both lists and therefore from the union. No path under
`.github/instructions/` and no path under `extensions/drm-copilot/resources/customizations/`
appears anywhere in either list; the only `.github/` path in the union is
`.github/workflows/_quality-checks.yml`.

## Acceptance for [P4-T10]

### Condition (a) — the list is non-empty and contains the workflow

| Check | Result |
| --- | --- |
| The union is non-empty | **PASS** — 37 distinct paths |
| The union contains `.github/workflows/_quality-checks.yml` | **PASS** — entry 1 of the committed name list |

**Condition (a): PASS.**

### Condition (b) — none of the four blocked policy paths is present

All four are absent from the working-tree list, from the committed name list, and therefore from
the union, per the table above. The exclusion holds for both lists independently, so it does not
pass merely by a blocked path being absent from one of them.

**Condition (b): PASS.** This is the working-tree half of AC-15; its committed half is P6-T2.

The unresolved human-interaction requirement arising from these four blocked paths is recorded
separately by P5-T3.

---

# [P4-T11] — the change is confined to the closed write set

This section is the amendment P4-T11 is directed to add to this artifact.

## Every path in the union maps to a declared write-set entry

The plan's Write set section declares **nine** entries. Each of the 37 union paths is mapped
below.

| Write-set entry | Declared path | Union paths matched | Count |
| --- | --- | --- | --- |
| 1 | `.github/workflows/_quality-checks.yml` — modified | committed #1 | 1 |
| 2 | `scripts/dev_tools/check_python_coverage_thresholds.py` — new production module | committed #26 | 1 |
| 3 | `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` — new test | committed #27 | 1 |
| 4 | `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` — new test | committed #28 | 1 |
| 5 | `docs/.../plan.2026-08-23T23-21.md` — this plan | committed #23, working-tree #1 (same path) | 1 |
| 6 | `docs/.../spec.md` — acceptance-criteria check-off only | committed #25 | 1 |
| 7 | `docs/.../evidence/` — **the entire evidence subtree** | committed #2 through #21, working-tree #2 through #10 | 29 |
| 8 | `docs/.../issue.md` — committed unmodified, not written by any task | committed #22 | 1 |
| 9 | `docs/.../research/2026-08-23T23-45-ci-coverage-target-remedy-research.md` — committed unmodified, not written by any task | committed #24 | 1 |

1 + 1 + 1 + 1 + 1 + 1 + 29 + 1 + 1 = **37**, which equals the union's distinct-path count. Every
path is accounted for and no path is unmatched.

### Notes on entry 7

Entry 7 is stated as the whole evidence subtree, not as a list of named artifacts, precisely so
that an artifact written by a process upstream of this plan cannot fall outside the closed write
set. Its 29 matched paths break down as: 10 committed `evidence/baseline/**` artifacts, 5
committed `evidence/other/**` preflight-findings artifacts, 2 committed `evidence/qa-gates/**`
artifacts, 3 committed `evidence/regression-testing/**` artifacts, and the 9 working-tree-only
artifacts this phase wrote (8 under `evidence/qa-gates/` and 1 under `evidence/other/`).

**The five preflight-findings artifacts are matched by the subtree wording, not by enumeration.**
The Write set section names four of them and states explicitly that its list "is an open
enumeration, not a closed set, and no task may treat them as a count". A fifth,
`preflight-findings.2026-08-24T13-21.md`, is present in the committed name list; it was written by
a preflight cycle that ran after the plan was last revised, is untracked at `origin/main`, is
edited by no task in this plan, and is covered by the subtree wording of entry 7 without amendment.
This is exactly the case the open-enumeration clause was written for, and it is recorded here so a
reviewer does not read the fifth artifact as a write-set escape.

### Notes on entries 8 and 9

`issue.md` and the research document are **not written by** this work item; they are **committed
by** it, unmodified, because the entire feature folder is untracked at `origin/main`. The Write set
section declares them for exactly this reason: both scope gates read a path list, not an edit list.
Their presence in the committed name list is expected and is not a write-set escape.

### `coverage.xml` is absent, as required

| Check | Result |
| --- | --- |
| `coverage.xml` in the working-tree derived path list | **ABSENT** |
| `coverage.xml` in the committed name list | **ABSENT** |
| `coverage.xml` in the union | **ABSENT** |

The tracked repository-root `coverage.xml` was overwritten in place by P4-T5's
`--cov-report=xml` run and was restored immediately afterwards by `git checkout -- coverage.xml`,
with `git status --porcelain -- coverage.xml` then producing no output. That restore is recorded
as commands 3 and 4 of
`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md`.
No rerun of this task was required.

### One further confirmation: the gitignored `.claude/state/` clear left no trace

The mechanically-necessary removal of `.claude/state/python-batch-budget.default.json` that caused
loop restart 1 touched a path that is gitignored in its entirety (`.gitignore` line 68). No
`.claude/` path appears in either list, confirming that the removal changed no path either gate
reads and that the closed write set is unaffected.

## Acceptance for [P4-T11]

### Condition (a) — the list is non-empty

**PASS** — the union holds 37 distinct paths; the working-tree list holds 10 and the committed
name list holds 28, so neither input is empty either.

### Condition (b) — every path falls under one of the nine write-set entries

**PASS** — the mapping table above accounts for all 37 union paths against the nine declared
entries, including entries 8 and 9 (which this plan does not edit but does commit) and including
every preflight-findings artifact under `evidence/other/`, however many there are, which the
widened entry 7 covers as part of the whole evidence subtree. `coverage.xml` does not appear. No
path outside the write set is present, so the phase does not halt.

---

Verdict: **PASS** on both conditions of [P4-T10] and on both conditions of [P4-T11].
