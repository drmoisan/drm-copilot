# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T04-19
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T04-19.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T04-19.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T04-19.md`
Head reviewed: `123f8335cb2954eb1355b1d3cceb20f5efbb2c30` (merge base `9a19be8e72ea479212e2e43c3ad766afb270fae6`)
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T04-19.md`

## Findings requiring remediation

### F1 — Coverage artifact absent for Python

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: One local run produces the artifact from this worktree; it needs no external party, policy decision, owner input, or CI result.

- Files: `artifacts/python/lcov.info` (generated, gitignored); new evidence under `evidence/qa-gates/`. No source change is expected.
- Problem: `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` is a changed Python file, so coverage verification is mandatory for Python. The artifact is absent. `pyproject.toml` `addopts` carries `--cov-report=lcov:artifacts/python/lcov.info` without `--cov`, so the recorded `pytest -n auto` gate produced none. The plan's `Coverage` Pre-Mortem bullet declined the task because no Python production file changed; the review contract has no test-only exception.
- Required change: from the worktree root, run once, in parallel: `poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing`. The form matches `.github/workflows/_quality-checks.yml`. Do not run an unqualified `poetry install`.
- Verification required: (a) the run exits 0 with zero failures; (b) `artifacts/python/lcov.info` exists after it; (c) a new `evidence/qa-gates/python-coverage.<timestamp>.md` records repo-wide line and branch percentages against the 85% and 75% defaults, beside the merge-base CI figure of 96.67% lines (33367 statements, 1111 missed, 12516 branches, 548 partial; run 42329060481, job 128271212043); (d) the artifact is on disk when re-review starts, because `artifacts/` is gitignored and the re-review reads it there.

## Non-remediation items (record only; recommended for the same cycle)

These are from `code-review.2026-11-07T04-19.md`. None blocks. They are related to this item and are cheapest to close before the first real ledger entry at stage C.

- NB-1 (Minor): reject a rooted, drive-prefixed, or `..` path in a `### Revert Block:` subsection, with a test.
- NB-2 (Minor): count `## Revert Steps` labels only outside fences, with a test.
- NB-3 (Minor): accept a stored patch path followed by sentence punctuation, or state in the README that the path is written in backticks.
- NB-4 (Minor): add date and issue to the README `## Summary` format and worked example, or record in `spec.md` that the index row satisfies this requirement of `issue.md`.
- NB-5 (Minor): add falsifying tests for three parser rules: an info-bearing fence line does not close a fence; the first repeated label wins; a level-one heading ends a section.
- Three Nit items need no action unless the same lines are touched.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `pytest -n auto` run for F1. If NB-1, NB-2, NB-3, or NB-5 changes the module or its tests, one `Invoke-PoshQCParallelTest` run follows, after format and lint.
- No acceptance-criterion text or checkbox changes. The six `[A]` items stay checked.
- No ledger entry is owed: this cycle reduces nothing.
- New-module line coverage stays at or above 85%, and the module stays below 700 lines (547 now).
- No Epic #1019 folder, `execution-environment`, or `atomic-plan-contract` file is edited.
