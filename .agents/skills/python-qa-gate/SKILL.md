---
name: python-qa-gate
description: Final QA gate for Python changes. Runs Black, Ruff, Pyright, and Pytest; compares static results and the tests and coverage of the single gate run to the Phase A baseline (the `Phase 0 baseline`), enforces zero-regression deltas, and reports before completion.
---

# Python QA Gate

Canonical procedure for the Phase D final quality gate that every Python change must pass before completion is reported.

## When to Use This Skill

Use this skill when:

- `python-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.

## Required Inputs

Before invoking this gate, the agent must have:

- a baseline record produced in Phase A (the plan's `Phase 0 baseline`), containing Ruff and Pyright findings for the in-scope files and the Pytest pass/fail status and per-file coverage status of one `poetry run pytest -n auto` run with coverage,
- the exact list of touched production and test files,
- a clean working tree (all planned edits committed to the working copy).

## Toolchain Execution Sequence

Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1. Do not stop the loop until all four steps complete without errors in a single pass.

1. `poetry run black .`
2. `poetry run ruff check .`
3. `poetry run pyright`
4. `env -u VIRTUAL_ENV sh .agents/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov-branch --cov-report=term-missing --cov`

If the environment prevents running any tool, stop and report the change as **unverified**. Do not declare completion.

## Delta Requirements (Zero-Regression Hard Gate)

Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run. All of the following must hold:

- **Ruff delta**: 0 new findings across the repository.
- **Pyright delta**: 0 new diagnostics across the repository.
- **Pytest delta**: zero failures in the single gate run and 0 new failing tests against the baseline.
- **Per-file coverage delta**: every changed file meets the coverage thresholds, read from the single gate run, and coverage for every touched file is greater than or equal to the baseline for that file; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
- **Overall coverage delta** (when the repo enforces it): overall coverage is greater than or equal to the baseline.
- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.

If any delta check fails, the agent must revert or fix immediately and rerun the full toolchain. Do not proceed to reporting until all deltas are clean.

## Required Reporting Block

Every completion response must include the following sections:

1. **Scope** — exact file list touched in this change.
2. **Baseline** — Ruff, Pyright, Pytest, and coverage status recorded in Phase A.
3. **Plan** — design and test-strategy summary, referencing the approved plan.
4. **Diffs** — patch-style or full-file replacements for scoped files only.
5. **QA Gate Results** — Ruff and Pyright deltas, failing-tests delta from the single gate run, per-file coverage delta against the baseline and the thresholds, and overall coverage delta when applicable. If any step could not be run, mark the corresponding line **unverified** and state why.

## Evidence Storage

Persist toolchain output according to `evidence-and-timestamp-conventions`:

- store baseline outputs (static and `Phase 0 baseline` test-suite) under `<FEATURE>/evidence/baseline/<timestamp>/`,
- store post-change outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`,
- use ISO-8601 UTC timestamps in folder names.

This location is canonical per evidence-and-timestamp-conventions and is not overridable.
See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the canonical evidence path authority.

The evidence paths must be referenced in the agent's completion message to satisfy the `SubagentStop` completion-artifact gate.

## Prohibited Shortcuts

- Do not disable, skip, or narrow any step of the toolchain to reach a clean result.
- Do not add Ruff `noqa`, Pyright `# type: ignore`, or test skips to suppress new findings introduced by the change.
- Do not report success based on partial or targeted runs. A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence, and the final gate is the single gate run.

## Test-Execution Launcher

The pytest gate runs through the test-execution launcher (issue #1158): `env -u VIRTUAL_ENV sh .agents/skills/test-execution-policy/scripts/run-test-suite.sh pytest` followed by the coverage arguments runs `poetry run pytest -n auto` with the integration and golden lanes excluded. A launcher exit 75 means the machine test-suite lock was busy: re-run the gate after the holder finishes and record it as a queue timeout, not a failure. The `test-execution-policy` skill states the rules.

Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
