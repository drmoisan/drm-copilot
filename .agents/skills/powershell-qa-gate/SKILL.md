---
name: powershell-qa-gate
description: Final QA gate for PowerShell changes. Runs PoshQC formatting, analysis, and testing with coverage where enforced; compares static results to the static baseline, reads tests and coverage from the single gate run, and reports before completion.
---

# PowerShell QA Gate

Canonical procedure for the Phase D final quality gate that every PowerShell change must pass before completion is reported.

## When to Use This Skill

Use this skill when:

- `powershell-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify the static tools against the static baseline recorded in Phase A, and the tests in the single gate run.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.

## Required Inputs

Before invoking this gate, the agent must have:

- a static baseline record produced in Phase A, containing PSScriptAnalyzer findings for the in-scope files,
- the exact list of touched production and test files,
- a clean working tree (all planned edits committed to the working copy).

## Toolchain Execution Sequence

Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1. Do not stop the loop until all steps complete without errors in a single pass.

1. `mcp__drm-copilot__run_poshqc_format`
2. `mcp__drm-copilot__run_poshqc_analyze`
3. One `Invoke-PoshQCParallelTest` run, through the route in the `execution-environment` brief. Read `ExitCode` first.
4. Coverage check (when enforced by task/repo flow) — use the Pester coverage output of the run in step 3.

If the environment prevents running any tool, stop and report the change as **unverified**. Do not declare completion.

## Gate Requirements (Hard Gate)

Compare the final static tool results to the static baseline recorded in Phase A, and read test and coverage results from the single gate run. All of the following must hold:

- **PSScriptAnalyzer delta**: 0 new findings across the repository.
- **Pester gate**: zero failures in the single gate run.
- **Per-file coverage**: every changed file meets the coverage thresholds, read from the single gate run, and new behavior is tested.
- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.

If any check fails, the agent must revert or fix immediately and rerun the full toolchain. Do not proceed to reporting until all checks are clean.

## Required Reporting Block

Every completion response must include the following sections:

1. **Scope** — exact file list touched in this change.
2. **Baseline** — PSScriptAnalyzer findings recorded in Phase A.
3. **Plan** — design and test-strategy summary, referencing the approved plan, including proposed script/module structure, minimal DI seams, Pester scenario-level test strategy, and external executable wrapper mock strategy.
4. **Diffs** — patch-style or full-file replacements for scoped files only.
5. **QA Gate Results** — PSScriptAnalyzer delta, failures in the single gate run, and per-file coverage against the thresholds. If any step could not be run, mark the corresponding line **unverified** and state why.

## Evidence Storage

Persist toolchain output according to `evidence-and-timestamp-conventions`:

- store static baseline outputs under `<FEATURE>/evidence/baseline/<timestamp>/`,
- store final gate outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`,
- use ISO-8601 UTC timestamps in folder names.

This location is canonical per evidence-and-timestamp-conventions and is not overridable.
See `.agents/skills/evidence-and-timestamp-conventions/SKILL.md` for the canonical evidence path authority.

The evidence paths must be referenced in the agent's completion message to satisfy the `SubagentStop` completion-artifact gate.

## Prohibited Shortcuts

- Do not disable, skip, or narrow any step of the toolchain to reach a clean result.
- Do not add PSScriptAnalyzer rule suppressions (`[Diagnostics.CodeAnalysis.SuppressMessageAttribute]` or `PSScriptAnalyzer` suppression comments) or Pester `-Skip` / `-Pending` to mask new findings introduced by the change.
- Do not report success based on partial or targeted runs. A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence, and the final gate is the single gate run.
- Do not mock `git`, `gh`, `actionlint`, or other executables directly; mock the wrapper function (for example `Invoke-GitExe`) per `.agents/skills/powershell/SKILL.md`.
