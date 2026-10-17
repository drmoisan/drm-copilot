# Digest Fail-Before (remediation cycle 3, expect-fail)

Timestamp: 2026-10-16T07-20
Command: poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `2 failed, 34 passed in 0.63s`
- BASE_TARGET_PASSED: 34
- FAILED lines (exactly two):
  - `FAILED tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/agents/epic-orchestrator.md-d5e5e3b015c810fd12911e0ecffee38e12122bcdf667683778c7bd6cbdf6f538]`
  - `FAILED tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-0b1a629aa81d78673e43c8f2bbd825d1377e0d6ae114e15e8bb65450c5d8b4f2]`
- No other failing node in this file; the failure set matches CI-1.
