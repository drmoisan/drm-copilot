---
name: csharp-qa-gate
description: Final QA gate for C# changes. Executes the full CSharpier -> .NET Analyzers -> Nullable Analysis -> xUnit toolchain (with architecture tests), compares static tool results against the static baseline, reads test and coverage results from the single gate run, and produces the required reporting block before the agent declares the change complete.
---

# C# QA Gate

Canonical procedure for the Phase D final quality gate that every C# change must pass before completion is reported.

## When to Use This Skill

Use this skill when:

- `csharp-typed-engineer` is about to declare a change complete.
- An executor has finished applying a planned batch and must verify the static tools against the static baseline recorded in Phase A, and the tests in the single gate run.
- A reviewer needs to confirm the toolchain was actually run and produced a clean pass.

## Required Inputs

Before invoking this gate, the agent must have:

- a static baseline record produced in Phase A, containing analyzer findings and compiler/nullable diagnostics for the in-scope files,
- the exact list of touched production and test files,
- a clean working tree (all planned edits committed to the working copy).

## Toolchain Execution Sequence

Run the full toolchain in this exact order. If any step fails or modifies files, fix the issue and restart from step 1. Do not stop the loop until all five steps complete without errors in a single pass.

Analyzer settings (`AnalysisLevel`, `AnalysisMode`, `TreatWarningsAsErrors`, `Nullable`) are centralized in `Directory.Build.props` and apply to every project automatically. Per-project analyzer-enablement properties are not used — central settings are authoritative.

1. `dotnet tool restore`
2. `dotnet csharpier check .`
3. `dotnet build` (analyzers and nullable analysis enforced via `Directory.Build.props`; `TreatWarningsAsErrors=true` fails the build on any warning)
4. `dotnet test tests/*.ArchitectureTests/*.csproj --no-build` (architecture tests against the `*.ArchitectureTests` project)
5. `dotnet test --collect:"XPlat Code Coverage"` (full unit-test pass with coverage)
6. Emit canonical coverage artifact: after `dotnet test` completes, copy the newest `TestResults/*/coverage.cobertura.xml` to `artifacts/csharp/coverage.xml` so local runs produce the same canonical artifact as CI. PowerShell sketch:

   ```pwsh
   New-Item -ItemType Directory -Force -Path artifacts/csharp | Out-Null
   $latest = Get-ChildItem TestResults -Recurse -Filter coverage.cobertura.xml |
     Sort-Object LastWriteTime -Descending | Select-Object -First 1
   if (-not $latest) { Write-Error 'No coverage.cobertura.xml found'; exit 1 }
   Copy-Item $latest.FullName artifacts/csharp/coverage.xml -Force
   ```

   The step must fail non-zero when no `coverage.cobertura.xml` is present.

If the environment prevents running any tool, stop and report the change as **unverified**. Do not declare completion.

## Gate Requirements (Hard Gate)

Compare the final static tool results to the static baseline recorded in Phase A, and read test and coverage results from the single gate run. All of the following must hold:

- **Analyzer delta**: 0 new findings across the repository.
- **Compiler / nullable delta**: 0 new diagnostics across the repository.
- **xUnit gate**: zero failures in the single gate run.
- **Architecture tests**: zero failures in the `*.ArchitectureTests` project.
- **Per-file coverage**: every changed file meets the coverage thresholds, read from the single gate run, and new behavior is tested.
- **New modules, classes, or methods**: coverage >= 90% for each new unit introduced in the batch.

If any check fails, the agent must revert or fix immediately and rerun the full toolchain. Do not proceed to reporting until all checks are clean.

## Required Reporting Block

Every completion response must include the following sections:

1. **Scope** — exact file list touched in this change.
2. **Baseline** — analyzer and compiler/nullable findings recorded in Phase A.
3. **Plan** — design and test-strategy summary, referencing the approved plan.
4. **Diffs** — patch-style or full-file replacements for scoped files only.
5. **QA Gate Results** — analyzer and compiler/nullable deltas, failures in the single gate run and the architecture tests, and per-file coverage against the thresholds. If any step could not be run, mark the corresponding line **unverified** and state why.

## Evidence Storage

Persist toolchain output according to `evidence-and-timestamp-conventions`:

- store static baseline outputs under `<FEATURE>/evidence/baseline/<timestamp>/`,
- store final gate outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`,
- use ISO-8601 UTC timestamps in folder names.

This location is canonical per evidence-and-timestamp-conventions and is not overridable.
See `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` for the canonical evidence path authority.

The evidence paths must be referenced in the agent's completion message to satisfy the `SubagentStop` completion-artifact gate.

## Prohibited Shortcuts

- Do not disable, skip, or narrow any step of the toolchain to reach a clean result.
- Do not add analyzer suppressions, `#pragma warning disable`, `#nullable disable`, or test `[Ignore]` attributes to suppress new findings introduced by the change.
- Do not report success based on partial or targeted runs. A focused run of one test file to debug a specific failure is debugging only; it is never a gate or evidence, and the final gate is the single gate run.
