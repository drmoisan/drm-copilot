# Gold Standard: invoke-csharp-engineer

## Objective

Invoke the csharp-typed-engineer worker to design, implement, and verify C# changes within typed repository boundaries. Applies CSharpier, .NET analyzers, nullable analysis, and MSTest with the one-to-three production-file small-path budget and zero-regression quality gates read from the single gate run and compared with the `Phase 0 baseline`. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: The skill takes an objective statement of what the change must accomplish, the files or entrypoints in scope, the constraints including public APIs that must be preserved, an optional approved plan (without which the worker delegates plan authoring to the planner before any edits), and an optional budget override of the form `budget: prod=<N>, test=<M>` subject to repository policy.
- **OB-2** Output Paths: The worker writes C# source and test files within the approved scope, baseline evidence (static and `Phase 0 baseline` test-suite) under `<FEATURE>/evidence/baseline/<timestamp>/` and post-change evidence under `<FEATURE>/evidence/qa-gates/<timestamp>/` at the non-overridable canonical location of `evidence-and-timestamp-conventions`, and plan artifacts under the active feature folder when the task is feature-scoped.
- **OB-3** Required Reporting Block: The worker returns a reporting block of five entries in order: Scope (the exact file list), Baseline (CSharpier, .NET Analyzers, Nullable Analysis, MSTest and coverage status), Plan (the design and test strategy), Diffs (patch-style or full-file replacements), and QA Gate Results (CSharpier, .NET Analyzers, Nullable Analysis, MSTest and coverage deltas against the baseline, with failures and per-file coverage read from the single gate run, or clearly marked **unverified**).
- **OB-4** Worker Routing: Worker: `csharp-typed-engineer`.
- **OB-5** Preloaded Contracts: The worker operates under eight preloaded shared skills, `policy-compliance-order`, `csharp-change-budget-router`, `atomic-plan-contract`, `csharp-qa-gate`, `acceptance-criteria-tracking`, `feature-promotion-lifecycle`, `remediation-handoff-atomic-planner` and `evidence-and-timestamp-conventions`, together with the C# coding rule scoped to `**/*.cs` and `**/*.csproj` files and the cross-language code-change, unit-test and tonality policies.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output Paths, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Required Reporting Block, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Worker Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Preloaded Contracts, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
