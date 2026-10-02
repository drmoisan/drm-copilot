# orchestrator-state-contract-correctness (Issue #771)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-state-contract-correctness/ (Issue #771)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub issue template.

- Issue: #771
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/771
- Last Updated: 2026-09-29
## Problem / Why

The orchestrator-state checkpoint contract is enforced by three validator implementations: Python (`scripts/dev_tools/validate_orchestrator_state.py` and `scripts/dev_tools/_orchestrator_state_routing.py`), PowerShell (`.claude/lib/orchestrator-state/*.psm1` and its bundled copy under `extensions/drm-copilot/resources/claude-customizations/`), and TypeScript (`extensions/drm-copilot/src/lib/validate/orchestrator-state-*.ts`). The halt and routing parts of that contract are inconsistent across the three runtimes and cannot express several legitimate orchestration outcomes:

- The TypeScript validator does not resolve the promotion-entry tool from `promotion-type`, so a bug-type large-route checkpoint passes Python and fails the MCP tool (#405, which also covers #623 item 3).
- `validate_orchestrator_state.py` has no CLI entry point, so the documented preflight command exits 0 without validating (#464).
- The completion gate demands a `potential_to_issue` receipt for an issue that already exists, so a run against a pre-existing issue must either file a duplicate or fail its own gate (#509).
- The `blocked_reason` enum cannot express a premise-falsified halt (#523).
- The two-value review verdict forces every blocker into remediation, including blockers that repository remediation cannot change (#484).

## Proposed Behavior

Deliver the contract fixes as one epic with five child features, executed in three dependency waves:

- Wave 1: #405 (TypeScript promotion-type resolution, parity with Python and PowerShell) and #464 (argparse CLI entry point that exits non-zero on errors or a missing path).
- Wave 2: #509 (accept evidence of a pre-existing issue in place of a promote-to-issue receipt; split the 595-line `_orchestrator_state_routing.py` below the 500-line cap; depends on #405) and #523 (represent a premise-falsified halt in structured fields across the validators and the `.agents/` and Codex skill documents; depends on #464).
- Wave 3: #484 (a review verdict that distinguishes autonomously remediable blockers from halt or wait conditions, with consistent remediation-cycle accounting; depends on #523).

The epic manifest and narrative live at `docs/features/epics/orchestrator-state-contract-correctness/epic.md`.

## Acceptance Criteria (early draft)

- [ ] The Python, PowerShell, and TypeScript validators return the same verdict and error list for the same checkpoint, including bug-type large-route checkpoints.
- [ ] The documented `validate_orchestrator_state` CLI validates and exits non-zero on errors or a missing path.
- [ ] A run against a pre-existing issue reaches a clean completion without a duplicate issue or a fabricated receipt.
- [ ] A premise-falsified halt is recoverable from structured checkpoint fields alone.
- [ ] A review blocker that repository remediation cannot change halts or waits without consuming a remediation cycle.
- [ ] All five child features merge into `epic/orchestrator-state-contract-correctness-integration`, and the integration branch merges into `main`.

## Constraints & Risks

- Issue #769 is being orchestrated in another session; its files (`.claude/hooks/enforce-powershell-batch-budget.ps1` and related tests) are out of scope.
- Enforcement hooks must not gain Python legs.
- Existing checkpoints that do not use the new fields must validate byte-identically.
- The bundled PowerShell copy under `extensions/drm-copilot/resources/claude-customizations/` must stay in parity with `.claude/lib/orchestrator-state/`.

## Test Conditions to Consider

- Cross-runtime parity fixtures run through the Python CLI, the PowerShell module, and the MCP tool.
- CLI exit-code tests for valid, invalid, and missing-path inputs.
- Completion-gate tests for a pre-existing issue with and without substitution evidence.
- Enum acceptance and rejection tests for the new halt representation.
- Review-verdict and cycle-accounting tests for remediable, external, and human-decision blockers.
