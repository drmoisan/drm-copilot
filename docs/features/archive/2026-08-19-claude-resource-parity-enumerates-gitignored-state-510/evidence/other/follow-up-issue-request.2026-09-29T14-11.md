# Follow-up Issue Request (P5-T13)

Timestamp: 2026-10-07T11-22

No issue number exists at authoring time. The orchestrator is requested to open a separate follow-up issue for the production push-down defect that issue #510 leaves out of scope (spec.md section `## Out of Scope and Follow-up`).

Defect: the push-down paths copy `.claude/state` and `.claude/worktrees` (gitignored local runtime state) into distributed payloads.

Research and spec citations:
- `scripts/dev_tools/push_down_claude_customizations.py:392`
- `scripts/dev_tools/push_down_copilot_customizations.py:172-174`
- `scripts/dev_tools/push_down_claude_filesystem.py:431-448`
- `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts:266-270`

Unverified items to include in the follow-up:
- Exposure of the Python pack-manifest completeness suite to the same local runtime state is unverified.
- The user-level ignore status of `.claude/settings.local.json` is unverified.
