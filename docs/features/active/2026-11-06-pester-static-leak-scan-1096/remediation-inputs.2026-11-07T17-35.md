# Remediation Inputs: Cycle 2 (Issue #1096)

Remediation-Mode: proportionate
Review-Verdict: REMEDIATION_REQUIRED

- Timestamp: 2026-11-07T17-35
- Branch: feature/pester-static-leak-scan-1096
- Pull request: #1112, reported `CONFLICTING` by GitHub right after creation, so no CI ran on it.
- Opened by: a merge conflict with `origin/main` after PR #1110 (issue #1097) merged. The cycle 1 re-audit (`remediation-inputs.2026-11-07T17-25.md`, `AWAITING_CI`) opened no cycle.

## Remediation-required findings

### MC-2 - Branch conflicts with origin/main after PR #1110

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: `git merge-tree --write-tree` of the branch head against `origin/main` reports one content conflict, in `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`. It auto-merges the six `execution-environment` brief copies and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
- Context: PR #1110 rebased the sections of entry 0001 over PR #1108 (commit subject carrying `reduction: 0001`), as this branch's cycle 1 also did. It added ledger entries 0002 to 0006 and their README index rows. Entry 0006 restores the test-suite baseline as the general rule. It changed `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, and the ledger suites `ProcessReductionLedger.Index.Tests.ps1` and `ProcessReductionLedger.Replay.Tests.ps1`. It also added Pester suites that the leak scan now reads.
- Required change: merge `origin/main` with a merge commit and resolve entry 0001 so that both sides survive:
  - `main`'s rebased sections and the `## Revert Steps` and patch handling of entries 0001 and 0006;
  - this branch's additions: the serial-command paths in `## Files Changed`, their Revert Blocks, the `Merge commit:` back-fill, and the reworded revert signal.
- Then re-establish this branch's guarantees on the merged tree:
  - every `Current` fence of entry 0001 occurs exactly once in its target, and the ledger replay and index suites pass;
  - the six brief copies are byte-identical and the brief contract tests and `parallel-gate-wording.Tests.ps1` pass with the leak-scan bullet in place;
  - `Invoke-PoshQCLeakScan` over the merged tree reports no unallowlisted finding, with any new finding classified and fixed or allowlisted under the main plan's `## Finding Classification Rule`;
  - the gates and the AC-34 and AC-35 comparisons against the Phase 0 baseline hold.
- Commit-subject rule: a commit that changes the serial-command wording of entry 0001 carries `reduction: 0001`; the merge commit itself carries no reduction token.

## Constraints

- Tests are parallel only: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run per gate, re-run only after a fix.
- No `.py` file is added. No edit to `.claude/rules/`, `.github/instructions/`, any `atomic-plan-contract` copy, or an Epic #1019 folder.
- `poshqc / PowerShell hook suites (Linux)` stays unchanged.

## Do not do

- Do not rebase or force-push.
- Do not re-open settled spec decisions, or edit entries 0002 to 0006.
