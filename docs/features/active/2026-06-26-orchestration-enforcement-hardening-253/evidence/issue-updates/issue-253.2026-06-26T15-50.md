# Issue #253 Update Mirror — Definition of Done

- Timestamp: 2026-06-26T15-50
- PostedAs: unknown (local mirror; no GitHub posting was requested in this execution)
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/253

## Update text

Orchestration enforcement hardening (Gaps 1–5 and routing-matrix agent-name reconciliation) is implemented and verified. Gap 6 (audit trail) remains out of scope (deferred) as documented in the spec and user story. All seven acceptance criteria are verified and checked off in `spec.md`, `user-story.md`, and `issue.md`.

### Acceptance criteria -> evidence mapping

- AC1 (routing validator wired at SubagentStop via injectable subprocess seam; `ROUTING_CONTRACT_BLOCKED`):
  - `evidence/regression-testing/fail-before-exception.gap1.2026-06-26T15-50.md` (fail-before dossier, P3-T1)
  - `evidence/qa-gates/powershell-final-qc.2026-06-26T15-50.md` (P3-T2 Pester contexts; 353/0 suite)
  - `.claude/hooks/validate-orchestrator-output.ps1` `Invoke-RoutingContractValidation`
- AC2 (sentinel/invalid issue-num & feature-folder rejection via helpers):
  - `evidence/regression-testing/gap2-fail-before.2026-06-26T15-50.md` (P4-T1)
  - `.claude/hooks/enforce-completion-helpers.ps1` `Test-IsValidIssueNum`, `Test-IsValidFeatureFolder` (P4-T2)
- AC3 (Edit-tool read-then-validate):
  - `evidence/regression-testing/gap3-fail-before.2026-06-26T15-50.md` (P4-T3)
  - `.claude/hooks/enforce-completion-consistency.ps1` `Resolve-EditedCheckpointContent` + `CheckpointReader` seam
- AC4 (remove literal "232"; remove ISSUE_232/ISSUE_232_BRANCH; route-driven requires_pr_gate):
  - `evidence/qa-gates/cross-language-verification.2026-06-26T15-50.md` (P6-T3 scan: 0 occurrences)
  - P2-T1 (`validate_orchestrator_state.py`), P4-T4 (`enforce-completion-consistency.ps1`), P5 (`enforce-orchestration-preimplementation-gate.ps1`)
- AC5 (validate_route_membership + validate_phase_completeness reject unknown routes):
  - `scripts/dev_tools/_orchestrator_state_routing.py` `validate_route_membership`, `validate_phase_completeness` (P2-T2, P2-T3)
  - `evidence/qa-gates/python-final-qc.2026-06-26T15-50.md`
- AC6 (real agent names; byte-identical mirror):
  - `evidence/qa-gates/config-parity.2026-06-26T15-50.md` (P1-T1; parity test passes; `feature-review`/`pr-author`)
- AC7 (all four toolchains pass; no coverage regression; existing tests pass):
  - `evidence/qa-gates/python-final-qc.2026-06-26T15-50.md` (1132 passed; Black/Ruff/Pyright clean)
  - `evidence/qa-gates/powershell-final-qc.2026-06-26T15-50.md` (353 passed; format/analyze clean; per-script coverage >= 85% line)

### Baselines

- `evidence/baseline/python-baseline.2026-06-26T15-50.md`
- `evidence/baseline/powershell-baseline.2026-06-26T15-50.md`
- `evidence/other/phase0-instructions-read.2026-06-26T15-50.md`

### Out of scope (untouched)

- The three pwsh-runner-independence working-tree changes under `tests/scripts/claude-hooks/*.Tests.ps1` (`enforce-pr-author-skill.Tests.ps1`, `enforce-promotion-mcp-only.Tests.ps1`, `validate-pr-author-output.Tests.ps1`) were not modified by this execution.
