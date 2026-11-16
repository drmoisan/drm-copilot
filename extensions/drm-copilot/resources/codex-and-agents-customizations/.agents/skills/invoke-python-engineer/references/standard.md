# Gold Standard: invoke-python-engineer

## Objective

Invoke the python-typed-engineer worker to design, implement, and verify Python changes within typed repository boundaries. Applies Black, Ruff, Pyright, and Pytest with a 1-3 production-file direct-mode budget, routing to the orchestrated large path above it, and zero-regression quality gates read from the single gate run and compared with the `Phase 0 baseline`. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** Inputs: Objective statement (what the change must accomplish).
- **OB-2** Output Paths: Python source and test files within the approved scope.
- **OB-3** Required Reporting Block: Baseline (Ruff, Pyright, Pytest, coverage status).
- **OB-4** Worker Routing: Worker: `python-typed-engineer`.
- **OB-5** Preloaded Contracts: `policy-compliance-order`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under Inputs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Output Paths, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Required Reporting Block, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Worker Routing, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-5) An expression of the skill states the behavior described under Preloaded Contracts, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-6** (OB-1, OB-2, OB-3, OB-4, OB-5) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
