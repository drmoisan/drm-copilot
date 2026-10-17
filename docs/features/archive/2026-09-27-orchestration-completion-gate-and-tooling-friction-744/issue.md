# orchestration-completion-gate-and-tooling-friction (Issue #744)

- Date captured: 2026-09-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestration-completion-gate-and-tooling-friction/ (Issue #744)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #744
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/744
- Last Updated: 2026-09-27
- Work Mode: full-bug

## Summary

Friction points in the orchestration tooling recurred across the three parallel runs of 2026-09-25 to 27. Each one cost a remediation or relay step. Consolidated here for one pass.

## Environment

- OS/version: Windows 11, Claude Code
- Python version: repo default
- Command/flags used: `validate_orchestration_artifacts.py`, the MCP tools, and the parallel-orchestrator merge gate
- Data source or fixture: the followups-2026-09-27 completion report; coordinator observations

## Steps to Reproduce

1. The completion check requires `ci_gate.verified_at`, which the orchestration skill never mentions (#709).
2. The strict completion check demands promotion receipts from items taken in by issue number, which were never promoted in-run (#710).
3. CI-dependent AC check-offs pushed after the parent's merge never reach main. #710's AC-8 commit `81726a3b` was stranded, and the parent cannot commit from the coordinator root. Mitigated in-prompt ("the child owns CI-dependent check-offs and pushes them before reporting done"); not yet codified in the skill.
4. The MCP `run_poshqc_test` tool overwrites the coverage file using the INSTALLED extension's settings, so newly registered files drop out; it takes no settings argument (#707 CR-3).
5. The `feature-review` agent has no MCP artifact validator (#714).
6. `collect_pr_context` pairs a file's last command with its first expected exit code, so intentional fail-before evidence is labelled "fail" (#708). It also listed `#AC-1`..`#AC-4` as auto-close issues (#706 FU-706-8). The installed extension may predate #622's fix; verify after a rebuild.
7. Local and CI coverage report different missed-line counts (1114 vs 1129), not investigated (#712).
8. The batch-budget hook needs a reset between batches (#709 CR-9).
9. Evidence timestamps run 4-18 minutes later than the commits that contain them (#706 FU-706-6).

## Expected Behavior

Documented, validator-consistent completion requirements; tools that respect the repository's own configuration; evidence labelled correctly.

## Actual Behavior

As above.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: the followups-2026-09-27 parallel-orchestrator completion report; `.claude/agent-memory/parallel-orchestrator/` notes.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Validator requirements drifted ahead of the skill documentation. Related memory notes: orchestrator-checkpoint-completion-gate-gotchas and mcp-poshqc-test-reads-installed-extension-settings.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: document `ci_gate.verified_at` and the receipt requirements in the skills, or relax them for issue-intake items; codify child ownership of CI-dependent check-offs in the parallel-orchestrate and orchestrate skills; add a settings argument to `run_poshqc_test` (or read the repository config); add a feature-review validator; fix the exit-code pairing in `collect_pr_context`; after an extension rebuild, verify the `#AC-n` behaviour.
- [ ] Integration scenario to retest: a parallel item completes with no relay-only steps.
- [ ] Manual verification notes: may split into several PRs.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
