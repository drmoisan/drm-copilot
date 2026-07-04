# `orchestration-enforcement-hardening` — User Story

- Issue: #253
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-26T15-43

## Story Statement

- As the maintainer of the orchestration runtime, I want the SubagentStop completion gate to invoke the authoritative routing-contract validator, so that an orchestration run cannot reach `next_step: "complete"` while deviating from its selected route's defined procedure.
- As the maintainer of the orchestration runtime, I want completion-consistency checks to reject sentinel and malformed `issue-num`/`feature-folder` values, so that placeholders such as `n/a` can no longer satisfy the presence checks.
- As the maintainer of the orchestration runtime, I want the Edit-tool path on the checkpoint to be validated by read-then-validate, so that completion cannot be asserted through a partial Edit that bypasses the Write-path checks.
- As the maintainer of the orchestration runtime, I want per-route requirements driven by a `requires_pr_gate` matrix field instead of a hardcoded issue number, so that PR-gate enforcement generalizes to any route and the issue-`232` special-casing is removed.
- As the maintainer of the orchestration runtime, I want unknown routes (for example `direct_powershell_engineer_remediation`) and incomplete phase coverage to be rejected, so that fabricated `execution_mode` values and skipped mandatory phases are caught.
- As an orchestrator delegating the large route, I want the routing matrix to reference only agents that exist, so that large-route runs are not blocked by receipts required from non-existent agents.

## Problem / Why

An orchestration run recorded `path_selected: "small"` (work-mode minor-audit) yet deviated from the small route's defined procedure: no promotion, `issue-num: "n/a"`, `feature-folder: "n/a"`, no atomic plan, no feature-review audit, and a fabricated `execution_mode: "direct_powershell_engineer_remediation"` that is not a key in `config/orchestration-routing.json`. The checkpoint still reached `next_step: "complete"`. No enforcement surface stopped it.

Research (`docs/research/20260626-orchestration-enforcement-hardening-research.md`) confirmed six gaps are still open after the merged #207/#230/#232 work, plus a routing-matrix agent-name defect. Separately, the `large` route's `required_agents` list references `feature-reviewer` and `commit-steward`, neither of which has a corresponding `.claude/agents/*.md` file; the routing validator would require receipts from agents that cannot be delegated to, blocking any large-route completion.

## Personas & Scenarios

- Persona: Orchestration runtime maintainer.
  - Who: the engineer responsible for the Claude Code orchestration enforcement surfaces (hooks and Python validators).
  - What they care about: that the enforcement surfaces actually prevent route deviation, not merely document it.
  - Constraints: no PowerShell reimplementation of the Python routing logic; existing checkpoints must keep validating; both routing JSON files must stay byte-identical; production files must stay under 500 lines.
  - Goals and frustrations: prevent a recurrence of the silent-deviation incident; frustrated that the prior #207/#230/#232 work left the completion gate able to pass a fabricated route.

- Scenario: An orchestrator attempts to complete a run that deviated from its route.
  - Who is acting: the `orchestrator` agent terminating a run.
  - What triggered the action: the orchestrator writes a checkpoint asserting `next_step: "complete"` with `path_selected` set to a route whose mandatory phases were not completed, or with a fabricated `execution_mode`, or with sentinel `issue-num`/`feature-folder` values.
  - Steps taken: the SubagentStop hook (`validate-orchestrator-output.ps1`) runs the structural checks, then invokes the routing-contract validator through the injectable subprocess seam against the on-disk checkpoint with `--require-complete`.
  - Obstacles/decisions: the validator detects the unknown route, missing receipts, or incomplete phases and returns an error list. The completion-consistency hook independently rejects sentinel `issue-num`/`feature-folder` values and validates Edit-tool patches via read-then-validate.
  - Expected outcome: the hook blocks DONE with `ROUTING_CONTRACT_BLOCKED: <error list>` (or the relevant named completion-consistency error). A clean run with a recognized route, valid evidence fields, and complete phases is allowed.

- Scenario: An orchestrator delegates the large route.
  - Who is acting: the `orchestrator` agent selecting the `large` route.
  - What triggered the action: a full-feature run requiring review and PR authoring.
  - Steps taken: the orchestrator delegates to the agents listed in the route's `required_agents`.
  - Obstacles/decisions: previously the list named `feature-reviewer` and `commit-steward`, which do not exist; after reconciliation it names `feature-review` and `pr-author`, which do exist.
  - Expected outcome: the routing validator can be satisfied by receipts from agents that can actually be delegated to, and `requires_pr_gate: true` on the `large` route drives the `pr_gate` requirement without any issue-number special-casing.

## Acceptance Criteria

- [x] AC1: `validate-orchestrator-output.ps1` invokes the routing-contract validator through an injectable subprocess seam and blocks DONE with `ROUTING_CONTRACT_BLOCKED: ...` on any routing error; allows when clean.
- [x] AC2: `enforce-completion-consistency.ps1` rejects sentinel/invalid `issue-num` (non-digit) and `feature-folder` (sentinel or not under `docs/features/active/`) values with named errors, via testable helpers.
- [x] AC3: `enforce-completion-consistency.ps1` validates completion-asserting Edit-tool patches by reading the on-disk checkpoint and applying the patch in memory; allows on missing file or non-matching patch.
- [x] AC4: The literal `"232"` no longer appears in any condition in `enforce-completion-consistency.ps1` or `enforce-orchestration-preimplementation-gate.ps1`; `ISSUE_232`/`ISSUE_232_BRANCH` are removed from `validate_orchestrator_state.py`; `pr_gate` is required only when the route's `requires_pr_gate` is true.
- [x] AC5: `validate_route_membership` rejects a checkpoint whose `route_id`/`path_selected` is not a routing-matrix key (including `direct_powershell_engineer_remediation`); phase-completeness is verified at completion.
- [x] AC6: `config/orchestration-routing.json` and its bundled mirror contain only real agent names in every route and remain byte-identical (parity test passes).
- [x] AC7: All four quality toolchains pass with no coverage regression (Python: Black/Ruff/Pyright/Pytest; PowerShell: PoshQC format/analyze/Pester), and existing tests continue to pass.

## Non-Goals

- Gap 6 (checkpoint-transition audit trail) is out of scope for this feature. It is diagnostic rather than preventive and is deferred until Gaps 1–5 are closed.
- No PowerShell reimplementation of the Python routing logic; the authoritative validator is invoked via subprocess only.
- No changes to required-check configuration or branch protection.
- No creation of new `feature-reviewer.md` or `commit-steward.md` agent personas; the matrix is reconciled to existing agents instead.
