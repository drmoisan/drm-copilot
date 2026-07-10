# validate-orchestration-ts-python-parity (Issue #343)

- Date captured: 2026-07-10
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/validate-orchestration-ts-python-parity/ (Issue #343)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #343
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/343
- Last Updated: 2026-07-10
## Summary

The TypeScript completion-gate port behind the MCP tool `validate_orchestration_artifacts` diverges from the authoritative Python validator: under `require_complete` the TypeScript path enforces `pr_gate` and `ci_gate` unconditionally and retains Issue #232 special-casing, while Python route-gates both gates from the routing matrix. The two surfaces must produce identical results for the same checkpoint.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (surface-independent; logic divergence)
- Python version: repository Poetry environment (`scripts/dev_tools`)
- Command/flags used: `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete` vs MCP `validate_orchestration_artifacts` with `require_complete: true`
- Data source or fixture: any `orchestrator-state.json` whose selected route does not require a PR/CI gate (`small`, `remediation`, `preparation`)

## Steps to Reproduce

1. Build a completion-safe checkpoint for the `preparation` route (no `pr_gate`, no `ci_gate`), e.g. the fixture in `tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py`.
2. Validate it with the Python CLI using `--require-complete`: it passes (`requires_ci_gate: false` exempts the CI gate; `requires_pr_gate` is absent so the PR gate is skipped).
3. Validate the same text through the MCP tool `validate_orchestration_artifacts` with `artifact_type: orchestrator-state` and `require_complete: true`.

## Expected Behavior

Both surfaces return the same error list. The TypeScript port's own module docstring states error-message parity with the Python source; behavioral parity must hold as well: `pr_gate` enforced only when the route's `requires_pr_gate` is `true`, `ci_gate` enforced only when the route's `requires_ci_gate` is not the literal `false`.

## Actual Behavior

The TypeScript path reports errors the Python validator does not:

- `Checkpoint completion validation failed: pr_gate must be an object with keys: ...`
- `Checkpoint completion validation failed: ci_gate must be an object with keys: ...`

`extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` calls `validateCompletionPrGate` and `validateCompletionCiGate` unconditionally under `requireComplete` and also calls `validateIssue232PromotionReceipts`, which Python replaced with route-driven enforcement.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `orchestrator-state-core.ts` lines around the `requireComplete` block: `errors.push(...validateCompletionPrGate(stateMap)); errors.push(...validateCompletionCiGate(stateMap));` with no routing-matrix consultation.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Impact: the MCP surface over-reports completion failures for `small`, `remediation`, and `preparation` route checkpoints. The authoritative enforcement path (SubagentStop hook -> Python CLI) is unaffected, but any agent or extension command that self-checks completion through the MCP tool receives false blocking errors, including epic-planner preparation runs introduced in commit 8aa25d2d.

## Suspected Cause / Notes

- The TypeScript port predates two Python changes: route-driven `pr_gate` enforcement (`route_requires_pr_gate` in `scripts/dev_tools/_orchestrator_state_routing.py`) and route-driven `ci_gate` enforcement (`route_requires_ci_gate`, commit 8aa25d2d).
- Files to inspect: `extensions/drm-copilot/src/lib/validate/orchestrator-state-completion.ts`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts`.
- The routing matrix is already injected into `validateRoutingContract`; the same matrix wiring can drive `routeRequiresPrGate`/`routeRequiresCiGate` ports.
- Python retains no Issue #232 special-casing; the TypeScript `validateIssue232PromotionReceipts` and `ISSUE_232_BRANCH` pin should be reconciled to match Python exactly.

## Proposed Fix / Validation Ideas

- [ ] Port `route_requires_pr_gate` and `route_requires_ci_gate` to `orchestrator-state-routing.ts` with identical fail-closed semantics and thread the routing matrix into the completion-gate calls in `orchestrator-state-core.ts`.
- [ ] Remove or align the Issue #232 special-casing with the Python source.
- [ ] Unit coverage areas: Jest tests mirroring `tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py` and the routing-contract suite, including the fail-closed matrix/route/flag edge cases.
- [ ] Integration scenario to retest: MCP `validate_orchestration_artifacts` with `require_complete: true` against a preparation-route checkpoint returns zero errors and against a gate-less large-route checkpoint returns the same errors as the Python CLI.
- [ ] Manual verification notes: run both surfaces against the same checkpoint text and diff the error lists; they must be identical.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
