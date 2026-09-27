# gate-suites-read-unmocked-local-epic-state (Issue #709)

- Date captured: 2026-09-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/gate-suites-read-unmocked-local-epic-state-709/ (Issue #709)

> Source: populated from the GitHub issue #709 body. The lifecycle record for this issue is not present on this branch; `new_active_feature_folder` found no potential source.

- Issue: #709
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/709
- Last Updated: 2026-09-26
- Work Mode: full-bug

## Summary

Pre-existing Pester suites for gates 1, 3 and 4 read local epic state through the unmocked `Get-EpicScopeCheckpointText` resolver. A gitignored local `artifacts/orchestration/epic-orchestrator-state.json` can therefore change their outcome on a developer machine.

Note: the GitHub issue body carries `- Work Mode: minor-audit`; this run was dispatched with work mode `full-bug`, which is the persisted mode for this folder.

## Environment

- OS/version: any developer machine
- Python version: n/a (Pester)
- Command/flags used: the Pester suites under `tests/scripts/claude-hooks/`
- Data source or fixture: a leftover local `artifacts/orchestration/epic-orchestrator-state.json`

## Steps to Reproduce

1. Leave an `artifacts/orchestration/epic-orchestrator-state.json` in the checkout (gitignored).
2. Run `enforce-pr-author-skill*.Tests.ps1`, `enforce-model-routing-receipt*.Tests.ps1` or `enforce-orchestration-preimplementation-gate*.Tests.ps1`, excluding the `*.EpicScope.Tests.ps1` suites.
3. Observe results that depend on the local file.

## Expected Behavior

The suites are hermetic: local, gitignored epic state cannot influence their results.

## Actual Behavior

The suites call through `EpicScopeResolution` without mocking `Get-EpicScopeCheckpointText`. This is inert in CI, which has no such file, and non-deterministic locally.

## Logs / Screenshots

- Snippet: #663 code review finding CR-4 (`code-review.2026-09-25T20-26.md`) and `evidence/other/follow-ups.md`, item 6.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Acceptance Criteria

- [ ] The non-EpicScope Pester suites for the gate-1 (`enforce-pr-author-skill`), gate-3 (`enforce-model-routing-receipt`) and gate-4 (`enforce-orchestration-preimplementation-gate`) hooks do not read local epic state: `Get-EpicScopeCheckpointText` (or the equivalent epic-state read seam) is isolated in every such suite that reaches `EpicScopeResolution`.
- [ ] The presence of a local, gitignored `artifacts/orchestration/epic-orchestrator-state.json` cannot change the result of any of those suites.
- [ ] A regression check demonstrates hermeticity without creating temporary files and without depending on gitignored state.
- [ ] The `*.EpicScope.Tests.ps1` suites keep their existing behavior.
- [ ] The full PowerShell toolchain (format, analyze, Pester) passes for the changed files.

## Source

From: docs/features/potential/2026-09-26-gate-suites-read-unmocked-local-epic-state.md (lifecycle record not present on this branch)
