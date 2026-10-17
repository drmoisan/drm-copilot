# Follow-Up Requests (Issue #509)

Timestamp: 2026-09-30T15-13
Tasks: [P8-T20], [P8-T21]

`atomic-executor` cannot call `mcp__drm-copilot__new_potential_entry`. The orchestrator creates one potential entry per section below after execution, using the short name and summary given.

## Follow-up 1: Copilot-surface promotion lifecycle

- Short name: `github-promotion-lifecycle-issue-adoption-path`
- Summary: add the `issue_adoption` pre-existing-issue path to `.github/skills/feature-promotion-lifecycle/SKILL.md` and its copy under `extensions/drm-copilot/resources/customizations/`, deferred by #509.

## Follow-up 2: promotion hook blocks read-only inspection

- Short name: `promotion-mcp-only-hook-blocks-readonly-inspection`
- Summary: `.claude/hooks/enforce-promotion-mcp-only.ps1` blocks read-only inspection because it matches the promotion tool name anywhere in a shell command; recorded by #509, hook changes excluded from epic #771.
