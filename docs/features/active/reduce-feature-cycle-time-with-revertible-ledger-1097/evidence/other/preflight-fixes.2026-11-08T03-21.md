# Preflight Fixes (Stage G)

Timestamp: 2026-11-08T03-21
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T12-43.md

## Fixes

1. `## Test Dispositions` | disposition table incomplete | A search of `tests/` for the edited file names found five existing suites that read the edited feature-review, orchestrate, and executor files and were not named: `test_push_down_issue_824_follow_ups.py`, `test_push_down_tier_rule_adoption_gate.py`, `test_orchestrator_state_remediation_docs.py`, `test_completion_gate_documentation_contracts.py`, and `test_scratch_location_contracts.py`. Each is unaffected by the design as written, so one row records them as unchanged with the reason: the line holding `governing repo-wide threshold` is kept and G3 is added beside it, new text states no `80%` or `90%` figure, and step 8, the remediation-input prefixes, `## Output Reporting`, and the executor scratch section are not edited. No task, file set, or assertion changed.

## Confirmed without change

- Chain prototype in SCRATCH: the branch head was copied into a scratch repository, every region named in `## Surfaces and Baseline-Adjacent Places` was edited at an anchor that matched exactly once, bundles were re-copied, a new test was created, and `patches/0009-less-evidence.patch` was generated as G4 states (53 files, 1 create hunk). With a `0009` entry and index row: ledger valid (9 rows), entry valid with its `PatchPath`, full chain 0 errors, `-StopBefore` replays for `0009`, `0008`, `0006`, and `0001` 0 errors each, all 16 source paths replayed at `0008` equal to the pre-edit text, the new test absent, and the baseline-token line lists equal on all 52 surface paths.
- [P1-T2] probe on unmodified code: `Get-OrchestratorStateRemediationLoopError` returns no error for a PASS entry followed by a `REMEDIATION_REQUIRED` entry with one `autonomous` finding; `Get-OrchestratorStateCompletionConcurrentReviewError` returns the verdict-PASS error under the key.
- G13: the branch-current Python CLI and the installed MCP validator both pass the plan; it holds 20 tasks and 165 physical lines, which also fits the lowered pair.
