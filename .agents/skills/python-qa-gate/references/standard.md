# Gold Standard: python-qa-gate

## Objective

Final QA gate for Python changes. Runs Black, Ruff, Pyright, and Pytest; compares static results and the tests and coverage of the single gate run to the Phase A baseline (the `Phase 0 baseline`), enforces zero-regression deltas, and reports before completion. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Required Inputs: Before the gate runs, a `Phase 0 baseline` record exists that holds the Ruff and Pyright findings for the in-scope files and the Pytest pass and fail status and per-file coverage status of one parallel `pytest -n auto` run with coverage, together with the exact list of touched production and test files and a clean working tree.
- **OB-2** Toolchain Execution Sequence: The toolchain runs in a fixed order of Black, Ruff, Pyright, and one parallel `pytest -n auto` run with branch coverage through the test-execution launcher; when any step fails or modifies files, the issue is fixed and the loop restarts from step 1 until all four steps complete without errors in a single pass.
- **OB-3** Delta Requirements (Zero-Regression Hard Gate): Compare the final results to the Phase A baseline (the `Phase 0 baseline`), reading test and coverage results from the single gate run.
- **OB-4** Required Reporting Block: Scope — exact file list touched in this change.
- **OB-5** Evidence Storage: Baseline outputs (static and `Phase 0 baseline` test-suite) are stored under `<FEATURE>/evidence/baseline/<timestamp>/` and post-change outputs under `<FEATURE>/evidence/qa-gates/<timestamp>/`, with ISO-8601 UTC timestamps in the folder names.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Required Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Toolchain Execution Sequence, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Delta Requirements (Zero-Regression Hard Gate), and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Required Reporting Block, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Evidence Storage, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
