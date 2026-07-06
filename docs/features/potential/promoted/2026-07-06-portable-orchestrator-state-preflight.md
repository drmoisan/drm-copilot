# portable-orchestrator-state-preflight (Issue #321)

- Date captured: 2026-07-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/portable-orchestrator-state-preflight/ (Issue #321)

- Issue: #321
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/321
- Last Updated: 2026-07-06
## Problem / Why

The pushed-down `.claude` enforcement hooks default their orchestrator-state validation `$Invoker` to
`python -m scripts.dev_tools.validate_orchestration_artifacts ...`. The push-down mechanism publishes
only `.claude`-relative paths from the pack manifests; `scripts/dev_tools` is not shipped. In a
consumer repo (e.g. TaskMaster) the module is absent, the invoker exits non-zero
(`ModuleNotFoundError`), and the hook blocks every well-formed `gh pr create --body-file` with
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (and, in the completion hook, blocks DONE). Additionally, the
extension ships from a bundled snapshot of `.claude/**`, so fixes to the live tree do not reach
consumer repos until the bundle is mirrored (byte-parity is enforced by a contract test).

## Proposed Behavior

Make the two hooks portable (Option A): a new portable module
`.claude/lib/orchestrator-state/OrchestratorState.psm1` (+ `OrchestratorStateCompletion.psm1`)
implements the PR-creation-readiness and completion presence checks in PowerShell, mirroring the
existing `.claude/lib/model-routing/ModelRouting.psm1` pattern. The hooks' default `$Invoker` uses
capability detection: authoritative Python CLI when importable (drm-copilot), portable PS module
otherwise (consumer repos). Both paths fail closed. The new modules ship via the `core` pack manifest,
and all changed `.claude/**` files are mirrored byte-identically into the extension bundle snapshot.

## Acceptance Criteria (early draft)

- [ ] Portable module implements PR-creation-readiness parity with
  `_orchestrator_state_pr_creation_readiness.py` and the completion presence checks; fails closed; < 500 lines.
- [ ] Both hooks use capability detection; injectable `$Invoker` seam and block-reason strings
  (`ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, `MODEL_ROUTING_BLOCKED:`) preserved.
- [ ] New module listed in `core.json`; changed `.claude/**` mirrored byte-identically into the bundle;
  the Python resource-contract parity test passes.
- [ ] Full PowerShell toolchain passes (format → analyze → Pester), coverage >= 85% line / >= 75%
  branch on changed files, no regression.
- [ ] Local feature-review clean of blocking findings.

## Constraints & Risks

- No full PowerShell port of the validator (Python remains authoritative in-repo). No new modules.
  Files < 500 lines. PowerShell 7+.

## Test Conditions to Consider

- [ ] Portable module: ready checkpoint passes; each rejection condition fails; fail-closed on missing
  file / invalid JSON / not-ready / uncovered delegated agent.
- [ ] Hooks: capability-detection routes to portable path when the Python probe is unavailable.
- [ ] Bundle byte-parity: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.

## Next Step

- [ ] Promote to GitHub issue (refactor template)
- [x] `docs/features/active/portable-orchestrator-state-preflight/` folder already exists with the
  implemented work.

## Implementation Status

Implemented, remediated (1 review cycle), and committed on branch work (commits `20abfaa`, `eb252d9`,
`660745e`, `612c627`); this issue is being opened to track the change through the standard PR + CI
workflow. Note: propagating the fix to consumer repos also requires a subsequent extension
rebuild/publish.
