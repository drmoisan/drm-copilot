# Remediation Inputs: Epic Child CI Opt-Out (#1233)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design

Orchestrator note (2026-11-24T17:59Z): design mode, because the root-cause fix edits `orchestrator-state-completion.ts`, outside the branch diff, and changes what the TypeScript `ci_gate` and `pr_gate` checks accept. The cycle fixes F2 at the root (`missingObjectKeys`) rather than inside the child-CI module only, so the pre-existing `ci_gate`/`pr_gate` null divergence is closed in this item. For the whitespace-set Minor, the decision (autonomous mode) is to record it as a known limitation in the `epic-child-ci-opt-out-issue-1233` rule section, as the reviewer offered: changing the blank-string semantics of all three validators for every gate is a wider behavior change than this item's scope, and the affected characters (U+0085, U+001C, U+FEFF) do not occur in clock-read timestamps, SHAs, or evidence paths.

The path is full because the prior cycle was light, and because the recommended fix edits `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts`, which is outside the branch diff, and changes what the TypeScript `ci_gate` and `pr_gate` checks accept (aligning them with Python).

- Issue: #1233
- Branch: `feature/epic-child-ci-opt-out-1233`
- Reviewed head: `502309bcd2de1b549fec6c154c3eee33dd9e402e` (merge base `c030729de4703f961ff27489d4890919f6e0587e`)
- Review artifacts:
  - `.dev/active/1233-epic-child-ci-opt-out/policy-audit.2026-11-24T17-50.md`
  - `.dev/active/1233-epic-child-ci-opt-out/code-review.2026-11-24T17-50.md`
  - `.dev/active/1233-epic-child-ci-opt-out/feature-audit.2026-11-24T17-50.md`
- Prior cycle: F1 of `remediation-inputs.2026-11-24T13-43.md` and its three related observations are closed.

## Blocking Findings

### F2: TypeScript validator treats a null local-QC field as present

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The cause is one condition in a repository TypeScript helper; the fix, the corpus fixtures, and the TypeScript unit rows are edits on this branch with no external service, owner decision, or policy hold.
Finding-Scope: contained

- File: `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts` (`missingObjectKeys`), reached from `extensions/drm-copilot/src/lib/validate/orchestrator-state-child-ci.ts` (`validateCompletionLocalQcGate`)
- Observed: `missingObjectKeys` counts a key as absent only when its value is `undefined` or a whitespace-only string. For `tests/fixtures/orchestrator_state_child_ci/opt-out-accepted.json` with `local_qc_gate.evidence_path` and `local_qc_gate.verified_at` set to JSON `null`, `validateCompletionGateEvidence` returns no error, while Python `validate_completion_gate_evidence` and PowerShell `Get-OrchestratorStateCompletionCiGateError` both return `Checkpoint completion validation failed: local_qc_gate missing required fields: evidence_path, verified_at.`. With `local_qc_gate.head_sha` and the last outcome's `head_sha` both `null`, Python and PowerShell return the missing-fields string for `head_sha` and the head-binding string; TypeScript returns only the head-binding string. The same helper makes TypeScript accept a `ci_gate` whose `head_sha` and `verified_at` are `null`, which Python rejects (pre-existing on `main`, same cause).
- Required fix: in `missingObjectKeys`, count `null` as absent (`item === undefined || item === null`), so the `local_qc_gate`, `ci_gate`, and `pr_gate` checks match Python. Add two corpus fixtures under `tests/fixtures/orchestrator_state_child_ci/`, each a copy of `opt-out-accepted.json` with one change and `expected_errors` equal to the Python output: `local-qc-gate-null-fields.json` (`evidence_path` and `verified_at` are `null`) and `local-qc-gate-null-heads.json` (the gate `head_sha` and the last outcome `head_sha` are `null`). Add TypeScript completion-test rows for a `ci_gate` and a `pr_gate` with `null` required fields. If the edit touches a region recorded by a process-reduction ledger entry, update that entry in the same commit.
- Fail-before: with the fixtures added and the helper unchanged, the Jest corpus rows of the two new fixtures fail and the pytest and Pester corpus rows pass; record the failing row names with `ExpectedExitCode: 1`.
- Verification: the three corpus suites (`tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1`, `tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py`, `extensions/drm-copilot/test/lib/validate/orchestrator-state-child-ci.test.ts`), the TypeScript completion tests that cover `missingObjectKeys`, the TypeScript static loop, and Jest coverage of `orchestrator-state-completion.ts` with no drop; then re-check spec S7 and user-story U7.

## Non-Blocking Observations

- Minor (fold into this cycle if convenient): the three blank-string tests use different whitespace sets (Python `str.strip`, TypeScript `trim`, PowerShell `IsNullOrWhiteSpace`). U+0085 is blank in Python and PowerShell only, U+001C in Python only, U+FEFF in TypeScript only. One named whitespace set applied in the three helpers, with one fixture per differing character, closes it; otherwise record it as a known limitation in the rule section.
- Info: ledger `0015` reads `Merge commit: pending (PR #1233)`, which names the issue number; back-fill the merge commit at the records stage.
- Pending CI: spec S19 needs the pull request's own `CI` run and is checked off by the item orchestrator at S9; it is not a finding.
- Uncommitted review changes in the item worktree: the S7 and U7 reversals in `spec.md` and `user-story.md`, and the four review artifacts.
