# Related Runtime File Review (P4-T7 / P4-T8) (#331)

Timestamp: 2026-07-07T21-08
Command: rg -n "epic-plan\.md|feature_folder" .claude/agents/epic-orchestrator.md .claude/agents/epic-review.md .claude/skills/review-epic/SKILL.md

Grep result (pre-edit):
- .claude/agents/epic-orchestrator.md:66 — `docs/features/epics/<epic-slug>/epic-plan.md`
- .claude/agents/epic-orchestrator.md:115 — `epic-plan.md` (manifest maintenance note)
- .claude/agents/epic-orchestrator.md:61,103,104 — `epic_feature_folder` / `epic_manifest_path`
  (checkpoint field names, matched on the "feature_folder" substring)
- .claude/agents/epic-review.md — no matches
- .claude/skills/review-epic/SKILL.md — no matches

Per-file determination:
- .claude/agents/epic-orchestrator.md — EDIT REQUIRED and made. Two `epic-plan.md`
  references (lines 66, 115) renamed to `epic.md`; the line-115 note also reinforces
  that `epic-status.md` is a generated-only projection. The `epic_feature_folder` and
  `epic_manifest_path` checkpoint field names are unchanged (they are JSON field
  identifiers, not the manifest filename); `epic_manifest_path` documented in the
  skill as pointing at `epic.md`. Mirror synced byte-identical (P4-T8).
- .claude/agents/epic-review.md — NO EDIT REQUIRED (no manifest-path or DAG-key
  reference). Mirror unchanged (no-op).
- .claude/skills/review-epic/SKILL.md — NO EDIT REQUIRED. Mirror unchanged (no-op).

Post-edit verification: `grep epic-plan.md` across the three files returns none.
epic-orchestrator.md mirror byte-identical to runtime
(extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md).
