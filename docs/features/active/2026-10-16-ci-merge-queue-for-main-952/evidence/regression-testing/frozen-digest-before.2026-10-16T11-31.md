# Frozen Digest Before (P6-T24, expect-fail)

Timestamp: 2026-10-16T11-31
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q -k test_frozen_epic_surface_matches_pinned_baseline_digest
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 2 failed, 34 deselected in 0.12s

Final summary line (verbatim): 2 failed, 34 deselected in 0.12s (contains `2 failed`, does not contain `passed`)

FOUND_AGENT=e0691d2a05dfd97b886694262eb900293f38d9927fc2803f7e4574af856ce740
FOUND_SKILL=84b0555d0db146274fc5bfb9f06909c0b892a1f59522cc9feb0312d08721cf30

AssertionError lines (verbatim):
- .claude/agents/epic-orchestrator.md must be byte-identical to its pre-feature state; expected SHA-256 c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d, found e0691d2a05dfd97b886694262eb900293f38d9927fc2803f7e4574af856ce740
- .claude/skills/epic-orchestrate/SKILL.md must be byte-identical to its pre-feature state; expected SHA-256 b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f, found 84b0555d0db146274fc5bfb9f06909c0b892a1f59522cc9feb0312d08721cf30

RowAttribution:
- `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d]`: FAIL. P6-T20 (Completion Requirements body text) and P6-T21 (two tools grants) changed the agent file.
- `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f]`: FAIL. P6-T14 to P6-T16 changed the skill file.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:171-180` still holds the pre-change digests.

Both epic files were at their final bytes for this phase when this run was taken (skill: P6-T14 to P6-T16; agent: P6-T20 and P6-T21).
