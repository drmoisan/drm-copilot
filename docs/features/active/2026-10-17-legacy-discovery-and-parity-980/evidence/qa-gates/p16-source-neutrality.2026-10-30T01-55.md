# P16-T8 Source neutrality

Timestamp: 2026-10-30T01-55
Task: [P16-T8] Run the repository and publication contracts under the tiered file-size policy.
Command: grep -rniE "taskmaster|\btmw\b" packages/discovery-runtime/src .claude/lib/discovery-validation .claude/hooks .codex/hooks .github/hooks extensions/drm-copilot/src (py, ps1, psm1, psd1, ts, json) -l; the same pattern over .github/skills/execution-environment/SKILL.md
EXIT_CODE: 1 (no match), 1 (no match)
Output Summary: No consumer-specific name in the core runtime, hooks, validation library or extension sources (0 files), and none in the execution-environment brief (0 lines); grep exits 1 when nothing matches. The consuming-name contract (`test_push_down_issue_824_follow_ups.py`, `test_brief_has_no_consuming_names`) also passes in the mirror record.
Run window 2026-10-30T01-53 to 01-55 UTC on the remediated tree (`git status --porcelain` empty at start and end).
Result: PASS
