# Stale Closed-Set Wording Search (P5-T7)

Timestamp: 2026-10-29T14-50
Command: grep -rn "can never be waived" .claude/rules .claude/skills .agents/skills extensions/drm-copilot/resources/
EXIT_CODE: 0
SearchScope: `.claude/rules`, `.claude/skills`, `.agents/skills`, `extensions/drm-copilot/resources/`
SearchPatterns: `can never be waived`
SearchResult: 2 hits
Output Summary: Both hits are the updated closed-set sentence (source and its byte-equal bundle copy). Neither names `new_active_feature_folder` as never waivable.

| File | Hit (read in full) | Names `new_active_feature_folder` as never waivable |
| --- | --- | --- |
| `.claude/rules/orchestrator-state.md` (`## Invariants (issue_adoption object)`) | "The closed waivable set is `potential_to_issue`, `new_potential_entry`, `new_potential_bug_entry`, and `new_active_feature_folder`; `new_active_feature_folder` is waived only together with a valid `feature_folder_record`. `collect_pr_context`, `validate_orchestration_artifacts`, and every other tool can never be waived." | No |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md` | identical text | No |
