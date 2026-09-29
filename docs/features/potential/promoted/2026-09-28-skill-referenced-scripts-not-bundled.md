# skill-referenced-scripts-not-bundled (Issue #762)

- Date captured: 2026-09-28
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/skill-referenced-scripts-not-bundled/ (Issue #762)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #762
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/762
- Last Updated: 2026-09-28
## Summary

Skills distributed by push-down reference scripts that are not included in the skill's bundle, so the skill is non-functional in consumer repositories. Rule: every script a skill references must be bundled with the skill (included in the push-down payload that carries the skill), regardless of the script's folder location.

## Environment

- OS/version: Windows 11 (consumer TaskMaster), CI ubuntu-latest
- Python version: n/a
- Command/flags used: `push_down_claude_customizations` MCP tool, then `/cleanup-merged-worktrees` in the consumer
- Data source or fixture: `extensions/drm-copilot/resources/claude-customizations/` bundle and `pack-manifests/*.json`

## Steps to Reproduce

1. Push down the Claude customizations into a consumer repository.
2. Invoke the `cleanup-merged-worktrees` skill in the consumer.
3. The skill runs `bash scripts/bash/cleanup-worktrees.sh`, which the bundle does not carry.

## Expected Behavior

Every script a skill invokes ships in the push-down payload together with the skill (present in the bundle and listed in the same pack manifest as the skill, or in `core`).

## Actual Behavior

`cleanup-merged-worktrees` invokes `scripts/bash/cleanup-worktrees.sh` and its nine sourced libraries; `orchestrate` and `epic-orchestrate` invoke `scripts/orchestration/Invoke-CiGateParser.ps1`; `parallel-orchestrate` and `parallel-remove` invoke Python CLIs under `scripts/dev_tools/`. None of these paths is in the bundle (the bundle publishes `.claude/**` and `config/**` only).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: consumer TaskMaster required a hand-ported copy of `scripts/bash/cleanup-worktrees.sh`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The bundle definition (`ROOT_FOLDERS` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, plus pack-manifest `paths`) does not include `scripts/**`, and no automated check ties a skill's script references to the bundle.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: pure reference-extraction and bundle-membership functions
- [x] Integration scenario to retest: repository-wide guard test over `.claude/skills/**` against the real bundle and manifests
- [ ] Manual verification notes

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
