# Phase 4 — Scope Gate: `pyproject.toml` Is Not in the Change (P4-T9)

Timestamp: 2026-08-25T22-33

Task: [P4-T9]
Class: command task — two commands, four required fields each.
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

This artifact is the working-tree half of AC-14. Its committed half is P6-T2.

---

## Declared substitution: the gate is evaluated against a UNION of two lists, which is strictly stronger than the plan's form

The Phase 4 preamble of the plan states that "at this point in the plan no commit has been made,
so the branch carries no commit of its own", and on that premise it directs the three Phase 4
scope gates to read the **working tree** and to assert a non-empty derived path list, because a
committed-diff listing would then be empty and would satisfy every exclusion vacuously (Trap 2).

**That premise no longer holds in this execution.** For resilience against abrupt termination,
this orchestration commits after each phase, so Phases 0 through 3 are already committed as
`49b12171`, `ed5f2ca4`, and `6f8633c8` and have been pushed. The Phase 1 through Phase 3 edits are
therefore **not** pending in the working tree, and the plan's non-empty condition (a) would fail
against a working-tree-only list for a reason that is not a defect: the edits exist and are
correct, they are simply already committed.

The substitution applied here, and stated explicitly so a reviewer can see the gate was
**strengthened rather than bypassed**:

1. The plan's command `git status --porcelain --untracked-files=all` is still run, and its raw
   output and its Trap-4-derived path list are still recorded in full, exactly as the task text
   requires.
2. `git diff --name-only origin/main...HEAD` is **additionally** run, and its name list is recorded
   in full under its own clearly labelled heading below. Per Trap 4 this command emits a bare name
   list, so only the unquoting step of that trap applies to it; the status-field-stripping and
   rename-expansion steps do not.
3. Condition **(a)** is evaluated against the **union** of the two lists.
4. Condition **(b)** is evaluated against the union as well, and must hold for **both** lists
   independently — the exclusion is not permitted to pass merely because the excluded path is
   absent from one list.

The union is non-empty and contains real evidence of the Phase 1 through Phase 3 edits, so the
gate remains falsifiable: a missing or wrong edit would show as a missing path in the union and
would fail condition (a), and a `pyproject.toml` edit anywhere — staged, unstaged, untracked, or
committed — would show in one of the two lists and would fail condition (b). Reading only the
working tree, as the plan's literal text directs, would have made condition (b) weaker, because a
committed `pyproject.toml` edit would have been invisible to it.

The committed-diff form of this assertion is **not** replaced by this substitution. P6-T2 re-runs
`git diff --name-only origin/main...HEAD` after the Phase 5 commit and evaluates the same
exclusions against the final committed state; that task remains the falsifiable committed form of
AC-14 and AC-15.

---

## Command 1 of 2 — the working-tree status

Timestamp: 2026-08-25T22-33
Command: `git status --porcelain --untracked-files=all`
EXIT_CODE: 0

Output Summary: Ten lines. Raw output recorded verbatim:

```text
 M docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/plan.2026-08-23T23-21.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/batch-budget-clear-before-toolchain-restart.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/coverage-threshold-enforcement.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-format-black.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-lint-ruff.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-test-coverage.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-python-typecheck-pyright.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/final-workflow-actionlint.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/toolchain-single-pass-transcript.md
?? docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md
```

### Derived path list — Trap 4 applied

All three derivation steps of Trap 4 were applied in order.

- **Step 1, strip the status field.** The first three characters of every line were removed. One
  line carries the unstaged-modification field ` M`; the remaining nine carry the untracked field
  `??`.
- **Step 2, expand a renamed entry into both paths.** No line carries the arrow form `old -> new`,
  so no expansion was required. Zero renames.
- **Step 3, unquote a quoted path.** No line's path is wrapped in double quotes, so no C-style
  unquoting was required. Every path is printable ASCII with no space, no double quote, and no
  backslash. Zero quoted paths.

The derived path list, ten entries:

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

## Command 2 of 2 — the committed name list (the declared substitution)

Timestamp: 2026-08-25T22-33
Command: `git diff --name-only origin/main...HEAD`
EXIT_CODE: 0

Output Summary: Twenty-eight lines. Recorded name list, verbatim and in full:

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
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-28.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T00-45.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T12-55.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-05.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/other/preflight-findings.2026-08-24T13-21.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md
docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-actionlint-post-edit.md
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

No entry is wrapped in double quotes, so the unquoting step produced no change.

## The union

The plan file appears in both lists, so the union holds **37 distinct paths**: the 28 committed
names plus the 9 working-tree-only evidence artifacts.

---

## Acceptance

### Condition (a) — the list is non-empty and contains the four required paths

Evaluated against the union.

| Required path | Present in the union? | Which list |
| --- | --- | --- |
| `.github/workflows/_quality-checks.yml` | **YES** | committed name list |
| `scripts/dev_tools/check_python_coverage_thresholds.py` | **YES** | committed name list |
| `tests/scripts/dev_tools/test_check_python_coverage_thresholds.py` | **YES** | committed name list |
| `tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py` | **YES** | committed name list |

The union is non-empty (37 paths) and all four required paths are present.

**Condition (a): PASS.**

### Condition (b) — the project manifest is not in the change

The repository-root `pyproject.toml` is checked against each list independently, as the
substitution requires.

| List | Contains `pyproject.toml`? |
| --- | --- |
| Working-tree derived path list (10 entries) | **NO** |
| Committed name list (28 entries) | **NO** |
| Union (37 entries) | **NO** |

The exclusion holds for both lists, so it does not pass merely by the manifest being absent from
one of them. This confirms the plan's Not-written declaration: `pyproject.toml` is not modified,
because its configured coverage source list is already correct and its omit list is already
compliant with the Coverage Exclusion Policy.

**Condition (b): PASS.** This is the working-tree half of AC-14; its committed half is P6-T2.

---

Verdict: **PASS** on both conditions.
