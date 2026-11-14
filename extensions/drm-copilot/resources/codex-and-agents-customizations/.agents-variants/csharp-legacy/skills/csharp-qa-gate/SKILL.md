---
name: csharp-qa-gate
description: Final QA gate for C# changes. Executes the full CSharpier -> .NET Analyzers -> Nullable Analysis -> MSTest toolchain, compares static tool results and the test and coverage results of the single gate run against the Phase A baseline (the `Phase 0 baseline` of the plan), enforces zero-regression deltas, and produces the required reporting block before the agent declares the change complete.
---

# C# QA Gate

Legacy C# variant resource for Codex push-down.

Canonical procedure for the Phase D final quality gate that every C# change must pass before completion is reported.

## When to Use This Skill

Use this skill when:

- `csharp-typed-engineer` is about to declare a change complete.
- An executor has reached a phase gate or the final QA loop and must verify zero regressions in the single gate run against the baseline captured in Phase A (the `Phase 0 baseline`). Test cadence follows `## Test Cadence (Mandatory)` in the `atomic-plan-contract` skill: a task check after each task, and the full toolchain loop at each phase gate and in the final QA loop.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.

## Required Inputs

Before invoking this gate, the agent must have:

- a baseline record produced in Phase A (the plan's `Phase 0 baseline`), containing analyzer findings and compiler/nullable diagnostics for the in-scope files and the MSTest pass/fail status and per-file coverage status of one test run,
- the exact list of touched production and test files,
- a clean working tree (all planned edits committed to the working copy).

## Toolchain Execution Sequence

Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1. Do not stop the loop until all four steps complete without errors in a single pass.

1. `dotnet tool restore` (when the manifest tool has not been restored), then `dotnet tool run csharpier format .` to apply formatting and `dotnet tool run csharpier check .` to verify read-only.
2. `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
3. `msbuild <solution>.sln /t:Rebuild /m /p:Configuration=Debug "/p:Platform=Any CPU" /p:TreatWarningsAsErrors=true`
4. `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage`

`/t:Rebuild /m` is intentional for the local gate: on a warm worktree `/t:Build` can skip `CoreCompile` through MSBuild incrementality and exit 0 without running analyzers or the compiler. CI may retain `/t:Build` on a cold checkout. Projects opt into nullable per file with `#nullable enable`; do not pass `/p:Nullable=enable`.

If the environment prevents running any tool, stop and report the change as **unverified**. Do not declare completion.

## Delta Requirements (Zero-Regression Hard Gate)

Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run. All of the following must hold:

- **Analyzer delta**: 0 new findings across the repository.
- **Compiler / nullable delta**: 0 new diagnostics across the repository.
- **MSTest delta**: zero failures in the single gate run and 0 new failing tests against the baseline.
- **Per-file coverage delta**: every changed file meets the coverage thresholds, read from the single gate run, and coverage for every touched file is greater than or equal to the baseline for that file; a new file has no pre-change run and is judged against the thresholds. New behavior is tested.
- **Overall coverage delta** (when the repo enforces it): overall coverage is greater than or equal to the baseline.
- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.

If any delta check fails, the agent must revert or fix immediately and rerun the full toolchain. Do not proceed to reporting until all deltas are clean.

## Required Reporting Block

Every completion response must include the following sections:

1. **Scope** — exact file list touched in this change.
2. **Baseline** — analyzer, compiler/nullable, MSTest, and coverage status recorded in Phase A.
3. **Plan** — design and test-strategy summary, referencing the approved plan.
4. **Diffs** — patch-style or full-file replacements for scoped files only.
5. **QA Gate Results** — analyzer and compiler/nullable deltas, failing-tests delta from the single gate run, per-file coverage delta against the baseline and the thresholds, and overall coverage delta when applicable. If any step could not be run, mark the corresponding line **unverified** and state why.

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
- Do not add analyzer suppressions, `#pragma warning disable`, `#nullable disable`, or test `[Ignore]` attributes to suppress new findings introduced by the change.
- Do not report success based on partial or targeted runs. A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence, and the final gate is the single gate run.

## Test-Execution Launcher

The test gate runs through the test-execution launcher (issue #1158): `sh .agents/skills/test-execution-policy/scripts/run-test-suite.sh dotnet-test` runs `dotnet test` with the integration and golden categories excluded. A repository whose tests run through another command configures a suite with runner `mstest` in `config/test-execution-policy.json` and names that suite instead. A launcher exit 75 means the machine test-suite lock was busy: re-run the gate after the holder finishes and record it as a queue timeout, not a failure. The `test-execution-policy` skill states the rules.
