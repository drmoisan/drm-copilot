# preimplementation-readiness-rejects-epic-feature-folder (Issue #664)

- Date captured: 2026-09-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-readiness-rejects-epic-feature-folder/ (Issue #664)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #664
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/664
- Last Updated: 2026-09-08
## Summary

`Test-OrchestrationReady` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` ends with the conjunct `featureFolder.StartsWith('docs/features/active/')`. An epic's home is `docs/features/epics/<slug>`, so the predicate is false for any correctly formed epic-level checkpoint and every `git add` or `git commit` from an epic orchestrator is denied. The issue #539 bookkeeping exemption does not help for the main-into-integration sync merge, whose conflict resolutions touch production paths.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, Claude Code runtime.
- Python version: not applicable (PowerShell hook).
- Command/flags used: `git add .gitattributes extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` during `git merge origin/main` on the integration branch.
- Data source or fixture: epic #655 integration checkpoint (issue-num 655, feature-folder `docs/features/epics/cleanup-merged-worktrees-hardening`, route_id epic, lifecycle_ready true; passes the validator plain, with `--require-pr-creation-ready`, and with `--require-model-routing`).

## Steps to Reproduce

1. Write a per-feature checkpoint whose `feature-folder` is an epic home under `docs/features/epics/`.
2. Merge `origin/main` into the integration branch and resolve a conflict in a production path.
3. Run `git add <resolved production path>`; observe `PREIMPLEMENTATION_GATE_BLOCKED`.

## Expected Behavior

Readiness accepts an epic home (`docs/features/epics/<slug>/`) when `route_id` is `epic`, or the gate reads `epic-orchestrator-state.json` for an epic-orchestrator caller, so the sync merge that must precede the integration PR (a `CONFLICTING` PR receives zero CI checks) can be committed by the orchestrator.

## Actual Behavior

The epic orchestrator resolved both conflicts correctly and could not stage them. The main session verified the resolutions and issued the add, merge commit, and push through the PowerShell tool, recording the route in the checkpoint's provenance block. The regenerated `epic-status.md` was likewise uncommittable from the orchestrator.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

```
PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.
```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Blocks the sync merge and the status-document commit of every epic; fifth enforcement gate found to lack an epic seam.

## Suspected Cause / Notes

- The prefix conjunct predates epics; #554 fixed the delegation leg for epic execution but not the command leg's readiness predicate.
- The exemption parser also rejects the mandated `Co-Authored-By: ... <email>` trailer characters, so even exempt-tree commits fail from the Bash tool; consider treating a `-m` operand as opaque text.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: Pester cases for readiness with `route_id: epic` and an epics-tree folder (allow), an epics-tree folder with a non-epic route (deny), and a `-m` message containing angle brackets and apostrophes inside a pathspec-bearing exempt commit (allow).
- [x] Integration scenario to retest: an epic orchestrator merging `origin/main` with a production-path conflict, staging and committing without a tool detour.
- [x] Manual verification notes: standalone feature runs keep the `docs/features/active/` requirement.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
