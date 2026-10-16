# concurrent-children-share-scratchpad-file-names (Issue #900)

- Date captured: 2026-10-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/concurrent-children-share-scratchpad-file-names/ (Issue #900)
- Origin: epic #852 enforcement-hook-precision (wave 1: #787 PR #856, #850 PR #857) and parallel run bug-burndown-2026-10-08; process defect

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #900
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/900
- Last Updated: 2026-10-11
## Summary

Concurrent child orchestrations in one session share a single session scratchpad, and their plans write helper scripts and outputs there under fixed names (`SCRATCH/run-ps.sh`, `SCRATCH/changed-line-coverage.ps1`, `SCRATCH/cov-final.txt`, `SCRATCH/region-probe.ps1`). Children running in parallel can therefore overwrite each other's scratch files. The #787 executor found same-named unrelated files already present and moved to a private subdirectory.

## Environment

- OS/version: Windows 11 Pro, Claude Code session with concurrent background child orchestrators
- Python version: n/a
- Command/flags used: atomic-plan Appendix H helper scripts written to `SCRATCH/`
- Data source or fixture: feature folders on main at 2ef8d361

## Steps to Reproduce

1. Run two child orchestrators concurrently in one session (for example epic wave 1 items #787 and #850).
2. Have both executors follow plans that write `SCRATCH/run-ps.sh` and `SCRATCH/changed-line-coverage.ps1`.
3. Compare each executor's scratch file contents with what its plan wrote.

## Expected Behavior

Each child writes scratch files to a location unique to that child (for example `SCRATCH/<issue>/`), so concurrent children cannot read or overwrite each other's helper scripts or outputs.

## Actual Behavior

- `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/evidence/other/scratch-smoke.2026-10-08T22-36.md:8`: "SCRATCH is the `exec787` subdirectory ... A dedicated subdirectory was used because the shared scratchpad already held unrelated files with the same names as several Appendix H scripts."
- #850 (`evidence/qa-gates/changed-line-coverage.2026-10-09T00-55.md:4`) and #787 (`evidence/qa-gates/final-changed-line-coverage.2026-10-08T22-36.md:4`), both in epic wave 1, use `SCRATCH/run-ps.sh` and `SCRATCH/changed-line-coverage.ps1`.
- `docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/plan.2026-10-08T13-54.md:233` instructs the executor to overwrite "the earlier copy" of `SCRATCH/region-probe.ps1`.
- The parallel planner state (`parallel-planner-state.json:2072`) records "Executor runs PowerShell via sh SCRATCH/run-ps.sh" for the parallel run's items.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: see the #787 scratch-smoke quote above. No record of a confirmed clobber that changed a result was found; the evidence is the observed name collision and the workaround.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. A child can run another child's helper script or read another child's coverage output and record it as its own evidence. This has not been observed to change a result, but it would not be detected if it did.

## Suspected Cause / Notes

- The scratchpad is session-scoped, not agent-scoped; planners use fixed `SCRATCH/` names without a per-item prefix.

## Proposed Fix / Validation Ideas

- [ ] Require planners (atomic-plan contract) to define `SCRATCH` as a per-item subdirectory, for example `<session scratchpad>/<issue>-<stamp>/`.
- [ ] Have the parallel and epic orchestrators pass a per-child scratch subdirectory in each child prompt.
- [ ] Unit coverage areas: a plan validator check that rejects bare `SCRATCH/<file>` paths without a per-item subdirectory.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch