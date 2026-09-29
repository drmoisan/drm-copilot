---
epic: orchestrator-state-contract-correctness
integration_branch: epic/orchestrator-state-contract-correctness-integration
created_at: 2026-09-29T14:45
intent:
  epic_type: enabler
  business_outcome_hypothesis: The orchestrator-state checkpoint contract is enforced identically by the Python, PowerShell, and TypeScript validators, and it can represent every legitimate halt and routing outcome without duplicate issues, fabricated receipts, or free-text-only halt reasons.
  leading_indicators:
    - A shared checkpoint fixture set yields the same verdict and error list from all three validators.
    - The documented validate_orchestrator_state CLI exits non-zero on an invalid checkpoint or a missing path.
    - A run against a pre-existing issue completes without a potential_to_issue receipt and without a gate exception.
    - Premise-falsified and non-remediable halts are distinguishable from unblocked runs by structured fields alone.
  nfrs:
    - Enforcement hooks gain no Python legs.
    - No production file exceeds the 500-line cap.
    - Existing checkpoints that do not use new fields validate byte-identically.
    - Line coverage >= 85% and branch coverage >= 75% where the tooling measures it.
features:
  - issue_num: 405
    feature_folder: 2026-09-29-ts-validator-promotion-type-parity-gap-405
    depends_on: []
  - issue_num: 464
    feature_folder: 2026-09-29-validate-orchestrator-state-cli-entry-point-464
    depends_on: []
  - issue_num: 509
    feature_folder: 2026-09-29-promotion-gate-lacks-preexisting-issue-branch-509
    depends_on: [405]
  - issue_num: 523
    feature_folder: 2026-09-29-blocked-reason-premise-falsified-halt-523
    depends_on: [464]
  - issue_num: 484
    feature_folder: 2026-09-29-orchestrator-remediation-loop-control-484
    depends_on: [523]
---

# Epic: Orchestrator-State Contract Correctness

Epic issue: #771.

## Goal

Make the halt and routing contract of the orchestrator-state checkpoint correct and consistent across the three validator runtimes:

- Python: `scripts/dev_tools/validate_orchestrator_state.py` and `scripts/dev_tools/_orchestrator_state_routing.py`.
- PowerShell: `.claude/lib/orchestrator-state/*.psm1` and the bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/`.
- TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-*.ts` (the MCP `validate_orchestration_artifacts` surface).

## Scope

- #405: resolve the promotion-entry MCP tool from `promotion-type` in the TypeScript validator, matching Python (PR #402) and the PowerShell completion gate. Covers #623 item 3, which reports the same disagreement between the PowerShell gate and the MCP validator.
- #464: give `validate_orchestrator_state.py` an argparse CLI entry point that prints errors and exits non-zero on errors or a missing path. The file is 492 lines, so the entry point must live in a separate module or the file must be split to stay under the 500-line cap.
- #509: let the completion gate accept recorded evidence of a pre-existing issue in place of a `potential_to_issue` receipt, in all three runtimes. `_orchestrator_state_routing.py` is 595 lines and must be split below the 500-line cap as part of this change.
- #523: make a premise-falsified halt expressible in structured checkpoint fields (a new `blocked_reason` member or an orthogonal field), in all three runtimes and in the `.agents/` and Codex skill documents that enumerate the values.
- #484: replace the two-value review verdict with one that separates autonomously remediable blockers from external, policy, awaiting-CI, and human-decision conditions, which halt or wait without consuming a remediation cycle; make remediation-cycle accounting consistent. The verdict is defined mainly in `.agents/skills/`.

## Non-Goals

- Issue #769 (batch-budget hooks: `.claude/hooks/enforce-powershell-batch-budget.ps1` and related files and tests) is orchestrated in another session. No child touches its files.
- #623 items 1 and 2 are handled by the parallel bug-burndown run; only item 3 is in this epic.
- Issue #343 (`pr_gate`/`ci_gate` route-gating parity) and the `require_pr_creation_ready` MCP parity potential entry are not in scope unless a child's research shows the fix is inseparable from its own.
- No enforcement hook gains a Python leg.

## Shared Design

- Python is the authoritative validator. PowerShell and TypeScript mirror its behavior; every contract change lands in all three runtimes in the same child, with parity tests over shared fixtures.
- The bundled PowerShell copy under `extensions/drm-copilot/resources/claude-customizations/` is updated in the same commit as `.claude/lib/orchestrator-state/`, and the existing bundle-parity tests must stay green.
- New fields and enum members are additive and presence-gated. A checkpoint that omits them validates byte-identically to today.
- Child issues already exist on GitHub. Children do not call `potential_to_issue`. Each child records the substitution under `human_interaction.requirements[]` citing #509, which is the defect that makes the receipt otherwise unavoidable. Once #509 merges into the integration branch, later waves may use the evidence form that #509 introduces.

## Decomposition and Waves

Wave numbers below are 0-indexed as computed by `scripts/dev_tools/epic_wave_computation.py` (`405: 0, 464: 0, 509: 1, 523: 1, 484: 2`).

| Wave | Issue | Complexity | Depends on | Rationale for the edge |
| --- | --- | --- | --- | --- |
| 0 | #405 | C2 | none | Localized TypeScript change mirroring an existing Python fix. |
| 0 | #464 | C2 | none | Localized Python CLI entry point with exit-code tests. |
| 1 | #509 | C3 | #405 | Changes the same `required_mcp_tools` receipt resolution in all three runtimes that #405 aligns; also splits the 595-line routing module. |
| 1 | #523 | C3 | #464 | Extends the `blocked_reason` contract in `validate_orchestrator_state.py`, the file #464 restructures; spans three runtimes and skill documents. |
| 2 | #484 | C4 | #523 | The new verdict's halt and wait outcomes are recorded through the halt representation #523 introduces; requires design. |

No other edges exist: #405/#464 and #509/#523 touch disjoint parts of the validator and can run concurrently within their waves.
