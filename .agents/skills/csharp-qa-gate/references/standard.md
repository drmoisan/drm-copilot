# Gold Standard: csharp-qa-gate

## Objective

Final QA gate for C# changes. Runs CSharpier, .NET analyzers, nullable analysis, and MSTest; compares static results and the tests and coverage of the single gate run to the Phase A baseline (the `Phase 0 baseline`), enforces zero-regression deltas, and reports before completion. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Inputs: Before the gate runs, a `Phase 0 baseline` record exists that holds the analyzer findings and compiler and nullable diagnostics for the in-scope files and the MSTest pass and fail status and per-file coverage status of one test run, together with the exact list of touched production and test files and a clean working tree.
- **OB-2** Toolchain Execution Sequence: The toolchain runs in a fixed order of CSharpier formatting, the analyzer build, the nullable build, and one test run with coverage; when any step fails or modifies files, the issue is fixed and the loop restarts from step 1 until all four steps complete without errors in a single pass.
- **OB-3** Delta Requirements (Zero-Regression Hard Gate): Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run.
- **OB-4** Required Reporting Block: Every completion response includes five sections in order: Scope (the exact file list touched in the change), Baseline (the analyzer, compiler and nullable, MSTest and coverage status recorded in Phase A), Plan (the design and test-strategy summary referencing the approved plan), Diffs (patch-style or full-file replacements for scoped files only), and QA Gate Results (analyzer and compiler and nullable deltas, the failing-tests delta from the single gate run, per-file coverage deltas against the baseline and the thresholds, and the overall coverage delta when applicable), with any step that could not run marked **unverified** and the reason stated.
- **OB-5** Evidence Storage: Baseline outputs (static and `Phase 0 baseline` test-suite) are stored under `<FEATURE>/evidence/baseline/<timestamp>/` and post-change outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`, with ISO-8601 UTC timestamps in the folder names.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Toolchain Execution Sequence, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Delta Requirements (Zero-Regression Hard Gate), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Required Reporting Block, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Evidence Storage, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
