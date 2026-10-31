# Preflight Fixes (Issue #1010, remediation cycle 1)

Timestamp: 2026-10-30T22-12
Plan: docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/remediation-plan.2026-10-30T21-59.md

## Fix 1

- Location: [P2-T1], existing-test disposition list.
- Defect class: citation correction (trivial).
- Observation: the task described O4 to O6 in `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` as `git -C <wt> add` and relative `git add` operands. O4 drives a `git -C` selector and O5 a relative `git add`, but O6 drives a Write leg (`Invoke-OrchestrationPreimplementationGateDecision` with a Write payload) that never reaches `Get-OrchestrationGateCommandOperandPath`.
- Change made: the citation now names each row's command form (O4 selector, O5 relative operand, O6 Write leg). The disposition (unchanged) and the assertion are not altered.

## Single-pass review notes

- Branch-current validator: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` reported `plan validation passed` (exit 0).
- Every cited file other than the suite this plan creates (suite 3) exists in the tree; the three policy-audit templates exist.
- Cited rows exist: B1 to B8 and T1 to T14 in suite 1; B1 to B9 and C1 to C17 in suite 2; the `keeps <File>` rows in suite 11; `AC-18 the parity test reads only the two canonical gate files` in the Parity suite; the `D4 row 6a`/`6b` rows and the `status $(date)` row in the CommandExemption suite.
- The three helper definitions are textually identical across the Claude and Codex `-epic-scope` files today, which matches the F1 fail-before exception reasoning.
- The P1-T4 expected-pass reasoning for the `-C HEAD` and `-c HEAD` B10 cases matches `Get-CommandLineGlobalOption` (git `WithArgument` lists `-C` and `-c`) and `Get-CommandLineInvocationOperand`, which applies that table after the subcommand.
- A search of `tests/scripts` for a `git commit` or `git add` command carrying an absolute token after an option found none outside the rows this plan adds.
