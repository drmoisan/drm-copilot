# Remediation Inputs: Epic Child CI Opt-Out (#1233)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Remediation-Mode: proportionate

Orchestrator note (2026-11-24T14:21Z): the cycle is proportionate rather than light because it also closes the related non-blocking observations below inside this item (owner rule: fix related review findings in the item): the merge-gate opt-out predicate reads `child_ci`, `epic_mode`, and `epic_context` case-insensitively through `Get-EpicMergeGateChildCiProperty` (the gate must read them ordinally, matching the validators and completion hooks, with Pester rows for case-variant keys in both runtimes' opt-out suites), the missing space in `$ciGate =(`, and the missing blank line between the #1233 and #1234 header paragraphs of the Codex gate (and its bundle copy). These changes stay within the branch diff plus tests and mirrors and change no acceptance criterion or public interface.

- Issue: #1233
- Branch: `feature/epic-child-ci-opt-out-1233`
- Reviewed head: `0fc83af8b03b74deed2615238faa8c203df942dd` (merge base `23458fade99f40e81b95ce86ed90805258479782`)
- Review artifacts:
  - `.dev/active/1233-epic-child-ci-opt-out/policy-audit.2026-11-24T13-43.md`
  - `.dev/active/1233-epic-child-ci-opt-out/code-review.2026-11-24T13-43.md`
  - `.dev/active/1233-epic-child-ci-opt-out/feature-audit.2026-11-24T13-43.md`

## Blocking Findings

### F1: PowerShell completion validator reads the new keys case-insensitively

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect is in one branch-added PowerShell function and its bundle copy; the fix, a corpus fixture, and the ledger revert-block update are all edits on this branch with no external dependency or owner decision.
Finding-Scope: contained

- File: `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` and `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1`
- Location: `Get-OrchestratorStateCompletionLocalQcGateError`
- Observed: the function reads `local_qc_gate.conclusion`, `local_qc_gate.head_sha`, `remediation_loop`, `review_outcomes`, and the last outcome's `head_sha` through `Get-CheckpointObjectMember`, and checks the `LOCAL_QC_GATE_KEYS` presence through `Get-MissingGateKey`; both match names without regard to case. For a checkpoint whose gate carries `"Conclusion": "success"` and `"Head_Sha": "<sha>"` and whose loop key is `"Remediation_Loop"`, the Python validator returns three errors (missing fields `conclusion, head_sha`; conclusion must be success; head binding) and the PowerShell validator returns none.
- Required fix: read each of those keys with `Get-CheckpointObjectOrdinalMember`, and check the `LOCAL_QC_GATE_KEYS` presence ordinally without changing the behavior of the existing `ci_gate` and `pr_gate` callers of `Get-MissingGateKey`. Add one corpus fixture under `tests/fixtures/orchestrator_state_child_ci/` with case-variant field and loop keys, whose `expected_errors` are the Python output, so the Python, TypeScript, and PowerShell suites all pin it. Re-mirror the bundle copy and update the `0014` ledger revert block for this module so the stored current text matches. In the same edit, restore the space in `$ciGate = (Get-CheckpointObjectMember ...` (code review Nit).
- Verification: run the three corpus suites (`tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`), the ledger suites (`ProcessReductionChain*`, `ProcessReductionLedger*`), and the bundle-parity contract tests; then re-check spec S7 and user-story U7.

## Light Fix Tasks

- [ ] [P0-T1] Fix F1 in `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` (`Get-OrchestratorStateCompletionLocalQcGateError`): read the new keys ordinally, add a case-variant-key corpus fixture under `tests/fixtures/orchestrator_state_child_ci/`, re-mirror the bundle copy, and update the `0014` ledger revert block for the module.

## Non-Blocking Observations

- Minor: the merge-gate opt-out predicate reads keys case-insensitively through `Get-EpicMergeGateChildCiProperty` (code review). Optional.
- Nit: the Codex gate header lacks a blank line between the #1233 and #1234 paragraphs (code review). Optional.
- Pending CI: spec S19 needs the pull request's own `CI` run and is checked off by the item orchestrator at S9; it is not a finding.
