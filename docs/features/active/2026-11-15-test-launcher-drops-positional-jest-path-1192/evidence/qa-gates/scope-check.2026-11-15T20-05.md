# Scope check, AC-9 (P3-T4)

Timestamp: 2026-11-15T20-05
Command: `git diff --name-only <merge-base of origin/main and HEAD> HEAD`; `git status --porcelain`; a count of `.py` paths in the diff list.
EXIT_CODE: 0
Output Summary:
- Production and test paths changed (tracked, from the merge-base diff): `.claude/hooks/test-execution-policy.ps1`, `.codex/hooks/test-execution-policy.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/test-execution-policy.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/test-execution-policy.ps1` (the four hook copies); `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` and `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` (the two edited test files); `extensions/drm-copilot/jest.config.cjs` (comment only).
- Every other path in the diff is under `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/` (FEATURE: evidence, plan, issue, spec, research), plus the promotion record `docs/features/potential/promoted/2026-11-15-test-launcher-drops-positional-jest-path.md`, which the orchestration promotion step created before execution began; this execution did not edit it.
- Untracked paths from `git status --porcelain` at the check: only new files under FEATURE evidence.
- Absent from the diff: `run-test-suite.sh`, `Invoke-TestSuite.ps1`, `run-jest.cjs`, `config/test-execution-policy.json`, and every copy of the `execution-environment` brief.
- `.py` paths in the diff: 0 (no Python added).
