---
name: powershell-qa-gate
description: Final QA gate for PowerShell changes. Runs PoshQC formatting, analysis, and testing with coverage where enforced; compares static results and the tests and coverage of the single gate run to the Phase A baseline (the `Phase 0 baseline`), enforces zero-regression deltas, and reports before completion.
---

# PowerShell QA Gate

Canonical procedure for the Phase D final quality gate that every PowerShell change must pass before completion is reported.

## When to Use This Skill

Use this skill when:

- `powershell-typed-engineer` is about to declare a change complete.
- An executor has reached the final QA loop or a remediation gate and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: the full test suite runs only at the `Phase 0 baseline` and in the final QA loop, a task check runs its test selection after each task, and each phase gate runs its unit stage over the union of the test selections of the phase's tasks.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.

## Required Inputs

Before invoking this gate, the agent must have:

- a baseline record produced in Phase A (the plan's `Phase 0 baseline`), containing PSScriptAnalyzer findings for the in-scope files and the Pester pass/fail status and per-file coverage status of one `Invoke-PoshQCParallelTest` run,
- the exact list of touched production and test files,
- a clean working tree (all planned edits committed to the working copy).

## Toolchain Execution Sequence

Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1. Do not stop the loop until all steps complete without errors in a single pass. In a remediation gate, the test step runs the cycle's test selection in coverage mode (the selected test files appended to the test command, or `-TestPath` for the launcher `pester` suite); the full suite runs only in the final QA loop.

1. `mcp__drm-copilot__run_poshqc_format`
2. `mcp__drm-copilot__run_poshqc_analyze`
3. One `Invoke-PoshQCParallelTest` run, through the route in the `execution-environment` brief. Read `ExitCode` first.
4. Coverage check (when enforced by task/repo flow) — use the Pester coverage output of the run in step 3.

If the environment prevents running any tool, stop and report the change as **unverified**. Do not declare completion.

## Delta Requirements (Zero-Regression Hard Gate)

Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run. All of the following must hold:

- **PSScriptAnalyzer delta**: 0 new findings across the repository.
- **Pester delta**: zero failures in the single gate run and 0 new failing tests against the baseline.
- **Per-file coverage delta**: every changed file meets the coverage thresholds, read from the single gate run, and coverage for every touched file is greater than or equal to the baseline for that file; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
- **Overall coverage delta** (final QA loop only, when the repo enforces it): overall coverage is greater than or equal to the baseline.
- **Remediation gate coverage**: in a remediation gate, the per-file coverage delta applies to the files the cycle changed, read from the remediation gate run against the thresholds and the `Phase 0 baseline`; the repository-wide figure comes from the orchestration's final-QC artifact and CI, not from the remediation gate run.
- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.

If any delta check fails, the agent must revert or fix immediately and rerun the full toolchain. Do not proceed to reporting until all deltas are clean.

## Required Reporting Block

Every completion response must include the following sections:

1. **Scope** — exact file list touched in this change.
2. **Baseline** — PSScriptAnalyzer, Pester, and coverage status recorded in Phase A.
3. **Plan** — design and test-strategy summary, referencing the approved plan, including proposed script/module structure, minimal DI seams, Pester scenario-level test strategy, and external executable wrapper mock strategy.
4. **Diffs** — patch-style or full-file replacements for scoped files only.
5. **QA Gate Results** — PSScriptAnalyzer delta, failing-tests delta from the single gate run, per-file coverage delta against the baseline and the thresholds, and overall coverage delta when applicable. If any step could not be run, mark the corresponding line **unverified** and state why.

## Evidence Storage

Persist toolchain output according to `evidence-and-timestamp-conventions`:

- store baseline outputs (static and `Phase 0 baseline` test-suite) under `<FEATURE>/evidence/baseline/<timestamp>/`,
- store post-change outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`,
- use ISO-8601 UTC timestamps in folder names.

This location is canonical per evidence-and-timestamp-conventions and is not overridable.
See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the canonical evidence path authority.

The evidence paths must be referenced in the agent's completion message to satisfy the `SubagentStop` completion-artifact gate.

## Prohibited Shortcuts

- Do not disable, skip, or narrow any step of the toolchain to reach a clean result. The remediation gate's test selection, defined by `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill, is not a narrowing.
- Do not add PSScriptAnalyzer rule suppressions (`[Diagnostics.CodeAnalysis.SuppressMessageAttribute]` or `PSScriptAnalyzer` suppression comments) or Pester `-Skip` / `-Pending` to mask new findings introduced by the change.
- The gate run of a remediation gate is the selection run that `## Test Cadence (Mandatory)` defines, and the final QA loop is the single gate run of the full suite. Any other partial or focused run, such as a run of one test file to debug a specific failure, is debugging only; it is never a gate or evidence.
- Do not mock `git`, `gh`, `actionlint`, or other executables directly; mock the wrapper function (for example `Invoke-GitExe`) per `.agents/skills/powershell/SKILL.md`.

## Test-Execution Launcher

The Pester gate runs through the test-execution launcher (issue #1158): `sh .agents/skills/test-execution-policy/scripts/run-test-suite.sh pester` runs one `Invoke-PoshQCParallelTest` run with the integration and golden lanes excluded. A launcher exit 75 means the machine test-suite lock was busy: re-run the gate after the holder finishes and record it as a queue timeout, not a failure. The `test-execution-policy` skill states the rules.

Local test gates exclude the integration and golden lanes: CI integration and golden lanes are evidence, and a step that would run a lane locally records a non-blocking deviation under evidence/other/.
