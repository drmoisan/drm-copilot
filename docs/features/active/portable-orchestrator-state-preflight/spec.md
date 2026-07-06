# portable-orchestrator-state-preflight - Refactor Spec

- **Issue:** none (tracked locally; no GitHub issue by scope decision)
- **Parent (optional):** none
- **Owner:** orchestrator
- **Last Updated:** 2026-07-06T13-54
- **Status:** Approved (Option A)
- **Version:** 0.2

## Intent & Outcomes

Pushed-down `.claude/hooks/*.ps1` enforcement hooks currently default their orchestrator-state
validation `$Invoker` to `python -m scripts.dev_tools.validate_orchestration_artifacts ...`. The
push-down mechanism publishes only `.claude`-relative paths from the pack manifests; `scripts/dev_tools`
is not shipped. In any consumer repo (e.g. TaskMaster) the module is absent, the invoker exits
non-zero (`ModuleNotFoundError`), and the hook blocks every well-formed `gh pr create --body-file`
with `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (and, in the completion hook, blocks DONE).

Desired end-state: the pushed-down hooks perform their orchestrator-state validation using a
self-contained, portable PowerShell module that travels with the `core` pack, so PR creation and the
completion gate work in consumer repos, while the authoritative Python validator remains in use inside
drm-copilot itself. Both code paths fail closed.

- Success metric: in a repo WITHOUT `scripts/dev_tools`, a well-formed `gh pr create --body-file
  artifacts/pr_body_<N>.md` against a PR-creation-ready checkpoint returns `permissionDecision: allow`;
  a missing/invalid/not-ready checkpoint still returns `deny` with the correct reason.

## Invariants (must not change)

- The five-check SHA-256 receipt verification order in `enforce-pr-author-skill.ps1` is unchanged.
- The block-reason strings (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, `MODEL_ROUTING_BLOCKED:`,
  `PR_AUTHOR_*`, etc.) and their decision order are unchanged.
- Both hooks continue to FAIL CLOSED: a missing checkpoint, invalid JSON, not-ready state, or
  (completion hook) a missing model-routing/completion receipt blocks.
- Inside drm-copilot (where `scripts/dev_tools` is importable), the authoritative Python CLI remains
  the validation path; behavior/output there is byte-equivalent to today.
- The injectable `$Invoker` seam remains, so existing Pester tests that inject a mock invoker keep working.
- `.claude/rules/orchestrator-state.md`'s statement that the Python validator is authoritative stays true.

## Scope (structural changes)

- New portable module `.claude/lib/orchestrator-state/OrchestratorState.psm1` mirroring the existing
  portable pattern `.claude/lib/model-routing/ModelRouting.psm1`. It reads the checkpoint JSON and
  implements the pushed-down-relevant checks in PowerShell:
  - PR-creation-readiness (parity with
    `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py`: required base keys present;
    `step5_status`..`step8_status` not `pending`/`blocked`; `blocked_reason` in {none/absent};
    `local_execution_overrides`/`delegation_bypasses` empty when present).
  - Completion presence checks used by the completion hook for `--require-complete
    --require-model-routing`: the presence-level gate (required keys, step statuses valid, and the
    model-routing required-once-delegated existence check — delegated-agent set ⊆
    `model_routing_receipts[].agent`). Per-receipt formula correctness may reuse the portable
    `ModelRouting.psm1` where practical; deep routing-contract receipt validation that requires the
    full Python authority is out of scope for the portable path (documented below).
- Repoint the default `$Invoker` in both hooks with capability detection: if `scripts.dev_tools` is
  importable, use the authoritative Python CLI (unchanged); otherwise call the portable PS module.
  Both return the same `{ ExitCode, Output }` / `{ HasErrors, ErrorText }` contract consumed downstream.
- Add `.claude/lib/orchestrator-state/OrchestratorState.psm1` (and confirm `ModelRouting.psm1`) to the
  `core` pack manifest so the module ships on push-down.

## Non-Goals

- No full PowerShell port of the entire `validate_orchestrator_state.py` validator (Option C rejected).
- No change to the MCP validator or the Python validator logic.
- No change to which checks are required by branch protection or CI.
- Fixing the repository-wide "no MCP documentation-retrieval tool" limitation noted in the runbook is
  out of scope.

## Dependencies / Touchpoints

- `.claude/hooks/enforce-pr-author-skill.ps1` (`Invoke-OrchestratorStatePreflight`).
- `.claude/hooks/validate-orchestrator-output.ps1` (`Invoke-RoutingContractValidation`).
- Push-down pack manifest(s) under `resources/claude-customizations/pack-manifests` (core pack) and
  the selection logic in `scripts/dev_tools/push_down_claude_pack_selection.py`.
- Existing Pester tests for both hooks.
- Reference parity source: `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` and the
  model-routing gate presence logic.

## Risks & Mitigations

- Risk: PS/Python parity drift for the readiness/presence checks. Mitigation: keep the portable check
  minimal and mirror the Python reference exactly; add Pester tests asserting the same accept/reject
  decisions on representative checkpoints. A config/behavior-parity note is added near both.
- Risk: capability detection misfires (e.g. python present but module import fails for another reason).
  Mitigation: detection probes the specific module import; any probe failure routes to the portable
  path (fail-closed semantics preserved because the portable path still blocks bad checkpoints).
- Risk: the new module is not shipped by push-down. Mitigation: explicit manifest task + a test/check
  that the `core` pack manifest lists the new module path.
- Rollback: revert the two hook invoker edits; the Python default returns. Low blast radius.

## Technical Specifications

- Files expected to change: the two hooks; new `.claude/lib/orchestrator-state/OrchestratorState.psm1`;
  the `core` pack manifest JSON; new Pester test file(s) mirroring test layout under `tests/`.
- Public interface: the portable module exposes advanced functions (e.g.
  `Test-OrchestratorStatePrCreationReadiness -CheckpointPath <path>` and a completion-gate equivalent)
  returning a structured result compatible with the hooks' existing `{ ExitCode, Output }` contract.
- Data flow: hook → capability detection → (Python CLI | portable PS module) → `{ HasErrors, ErrorText }`.
- Compatibility: PowerShell 7+; no new modules; files < 500 lines.

## Test Strategy

- Pester tests for the portable module: ready checkpoint → pass; each rejection condition
  (missing keys, step pending/blocked, blocked_reason set, non-empty override list, missing/invalid
  JSON) → fail with a message. Completion-gate presence checks: delegated-agent set not covered by
  routing receipts → fail; covered → pass.
- Hook tests: capability-detection seam routes to the portable path when the Python probe fails, and
  to the Python path when it succeeds; both preserve fail-closed behavior and existing block reasons.
- Toolchain: PoshQC format → PSScriptAnalyzer → Pester (per `.claude/rules/powershell.md`), coverage
  >= 85% line / >= 75% branch on changed files; no regression.
- Determinism: no network, no PATH/profile reliance, mock the wrapper/probe seam (never mock `python`
  directly — mock the injected probe/invoker).

## Acceptance Criteria

- [x] AC1: New portable module `.claude/lib/orchestrator-state/OrchestratorState.psm1` implements
  PR-creation-readiness parity with `_orchestrator_state_pr_creation_readiness.py` and the
  completion-gate presence checks, fails closed, and is < 500 lines.
- [x] AC2: `enforce-pr-author-skill.ps1` `Invoke-OrchestratorStatePreflight` default `$Invoker` uses
  capability detection: authoritative Python CLI when `scripts.dev_tools` is importable, portable PS
  module otherwise; the injectable-seam contract and all block reasons are preserved.
- [x] AC3: `validate-orchestrator-output.ps1` `Invoke-RoutingContractValidation` default `$Invoker`
  applies the same capability detection for `--require-complete --require-model-routing`, preserving
  `MODEL_ROUTING_BLOCKED:` and completion fail-closed behavior.
- [x] AC4: The new portable module is listed in the `core` pack manifest so push-down ships it;
  a test or check verifies its presence in the manifest.
- [x] AC5: In a simulated no-`scripts/dev_tools` environment, a well-formed `gh pr create --body-file`
  against a ready checkpoint is allowed; a missing/not-ready checkpoint is denied with the correct
  reason. Inside drm-copilot, behavior is unchanged.
- [x] AC6: Full PowerShell toolchain passes (PoshQC format → PSScriptAnalyzer → Pester) with coverage
  >= 85% line / >= 75% branch on changed files; no coverage regression.
- [x] AC7: Local feature-review (policy-audit, code-review, feature-audit) is clean of blocking findings.

## Definition of Done

- [ ] Structure matches this spec; both hooks portable and fail-closed
- [ ] Invariants validated with Pester tests (parity + block reasons preserved)
- [ ] Push-down manifest ships the new module
- [ ] Edge cases and error handling verified
- [ ] Tests, analyzer, and format clean
- [ ] Toolchain pass completed (format → analyze → test)
