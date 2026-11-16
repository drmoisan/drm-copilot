# Gold Standard: csharp-qa-gate

## Objective

Final QA gate for C# changes. Runs CSharpier, .NET analyzers, nullable analysis, and MSTest; compares static results and the tests and coverage of the single gate run to the Phase A baseline (the `Phase 0 baseline`), enforces zero-regression deltas, and reports before completion. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Inputs: A baseline record produced in Phase A (the plan's `Phase 0 baseline`), containing analyzer findings and compiler/nullable diagnostics for the in-scope files and the MSTest pass/fail status and per-file coverage status of one test run,.
- **OB-2** Toolchain Execution Sequence: Run the full toolchain in this exact order.
- **OB-3** Delta Requirements (Zero-Regression Hard Gate): Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run.
- **OB-4** Required Reporting Block: Scope — exact file list touched in this change.
- **OB-5** Evidence Storage: Store baseline outputs (static and `Phase 0 baseline` test-suite) under `<FEATURE>/evidence/baseline/<timestamp>/`,.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Toolchain Execution Sequence, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Delta Requirements (Zero-Regression Hard Gate), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Required Reporting Block, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Evidence Storage, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
