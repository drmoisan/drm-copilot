# Changed Production File Sets

Timestamp: 2026-10-11T01-17
Task: [P0-T7]
Command: git diff --name-only 8ee1b76e64c02ce5e399baac1fc201efad819d69...HEAD -- 'extensions/drm-copilot/src/*.ts'; git diff --name-only 8ee1b76e64c02ce5e399baac1fc201efad819d69...HEAD -- 'scripts/dev_tools/*.py' 'src/*.py'; git status --porcelain -- extensions/drm-copilot/src scripts/dev_tools
EXIT_CODE: 0

## TS set (34 files; no `.d.ts` path was present to drop)

1. extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts
2. extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts
3. extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts
4. extensions/drm-copilot/src/lib/codex-native-converter/models.ts
5. extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts
6. extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts
7. extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts
8. extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts
9. extensions/drm-copilot/src/lib/codex-native-converter/validation.ts
10. extensions/drm-copilot/src/lib/pr-context/autoclose.ts
11. extensions/drm-copilot/src/lib/pr-context/collector-core.ts
12. extensions/drm-copilot/src/lib/pr-context/collector-output.ts
13. extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts
14. extensions/drm-copilot/src/lib/pr-context/feature-docs.ts
15. extensions/drm-copilot/src/lib/pr-context/models.ts
16. extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts
17. extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts
18. extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts
19. extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
20. extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts
21. extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts
22. extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts
23. extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts
24. extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts
25. extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts
26. extensions/drm-copilot/src/lib/string-ordering.ts
27. extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts
28. extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts
29. extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
30. extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts
31. extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts
32. extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts
33. extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts
34. extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts

## Python set (13 files)

1. scripts/dev_tools/_blast_radius_extraction.py
2. scripts/dev_tools/_blast_radius_token_shapes.py
3. scripts/dev_tools/_orchestrator_state_issue_adoption.py
4. scripts/dev_tools/check_quality_tiers.py
5. scripts/dev_tools/potential_to_issue.py
6. scripts/dev_tools/push_down_claude_customizations.py
7. scripts/dev_tools/push_down_claude_filesystem.py
8. scripts/dev_tools/push_down_claude_gitignore_merge.py
9. scripts/dev_tools/push_down_claude_pack_selection.py
10. scripts/dev_tools/skill_bundle_contract.py
11. scripts/dev_tools/validate_epic_orchestrator_state.py
12. scripts/dev_tools/validate_epic_planner_state.py
13. scripts/dev_tools/validate_orchestration_artifacts.py

## Companion porcelain check

`git status --porcelain -- extensions/drm-copilot/src scripts/dev_tools` output: (empty)

Output Summary: TS set 34 files, Python set 13 files; both counts match the remediation inputs (34 TS, 13 Python). No uncommitted production change in either directory.
