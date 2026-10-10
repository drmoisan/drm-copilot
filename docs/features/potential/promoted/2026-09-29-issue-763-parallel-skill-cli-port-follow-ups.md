# Follow-ups surfaced by issue #763 preparation (Issue #791)

- Date captured: 2026-09-29
- Author: epic-planner (epic #770, `push-down-payload-correctness`)
- Status: Promoted -> docs/features/active/Follow-ups_surfaced_by_issue_763_preparation/ (Issue #791)
- Related: #763, #734

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #791
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/791
- Last Updated: 2026-09-30
## Summary

Preparation of #763 surfaced four follow-ups: a skill-bundle guard regex defect (FU-763-5), remaining unbundled Python calls in `parallel-remove` (FU-763-3), an unused permission grant (FU-763-1), and a missing permission entry for the ported abandon script (FU-763-2). FU-763-4 (`quality-tiers.yml` does not exist) is already tracked by #734 (`quality-tiers-yml-missing-and-unenforced`, open) and is deliberately excluded from this issue. Source: `docs/features/active/2026-09-28-parallel-skills-invoke-unbundled-python-clis-763/spec.md` (decisions D4, D6, D7) and the #763 preflight round 2.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: skill-bundle contract check; `parallel-remove` steps 2, 3 and 6; a run of the ported abandon script
- Data source or fixture: main at ae7c7779

## Steps to Reproduce

1. FU-763-5: author a skill whose bash invocation sits directly under a `bash` code fence and run the skill-bundle guard.
2. FU-763-3: follow `parallel-remove` steps 2, 3 and 6 in a consumer repository without Poetry.
3. FU-763-2: invoke `.claude/lib/bash/abandon-parallel-item.sh` in a session that uses the repository permissions.
4. FU-763-1: search `.claude/agents/parallel-orchestrator.md` callers for use of `Bash(poetry run python -m *)`.

## Expected Behavior

The guard extracts every bash invocation, `parallel-remove` runs without Poetry, the abandon script runs without a permission prompt through a narrow allow entry, and no unused grant remains.

## Actual Behavior

- FU-763-5: the invocation pattern in `scripts/dev_tools/skill_bundle_contract.py` (`_INVOCATION_PATTERNS`, the `bash|sh|source` entry at line 52) can match across the newline after a `bash` fence info string and consume the invocation's interpreter word, so the guard does not extract an invocation directly under a bash fence. #763 works around this with a `shell` fence and leaves the regex defect unfixed, so any skill that uses a bash fence can bypass the guard.
- FU-763-3: `.claude/skills/parallel-remove/SKILL.md` (steps around lines 77 and 121) still calls `scripts/dev_tools/parallel_mutation_protocol.py`, which the guard does not detect; the steps are unbundled in a consumer repository without Poetry.
- FU-763-2: `.claude/settings.json` has no allow entry matching `abandon-parallel-item.sh` (the old invocation matched `Bash(poetry run *)`, line 6), so the ported script prompts.
- FU-763-1: `.claude/agents/parallel-orchestrator.md:17` grants `Bash(poetry run python -m *)`; after the #763 port none of the named callers use it, to be confirmed.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: the file references above were verified by reading main at ae7c7779; the guard defect was not re-executed.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

FU-763-5 and FU-763-3 let unbundled invocations pass the guard; FU-763-1 and FU-763-2 are permission-surface cleanup.

## Suspected Cause / Notes

Suggested grouping: fix FU-763-5 and FU-763-3 first (both let unbundled invocations bypass the guard); FU-763-1 and FU-763-2 together (permission surface after the port). Do not address FU-763-4 here; it is tracked by #734.

## Proposed Fix / Validation Ideas

- [ ] Fix the invocation regex so a bash fence info string cannot be consumed as part of the match, with a test for an invocation directly under a bash fence.
- [ ] Port or bundle the `parallel-remove` steps 2, 3 and 6 logic so the skill-bundle guard detects and satisfies them.
- [ ] Add a narrowly scoped allow entry for the abandon script and remove the unused `poetry run python -m` grant if no caller needs it.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
