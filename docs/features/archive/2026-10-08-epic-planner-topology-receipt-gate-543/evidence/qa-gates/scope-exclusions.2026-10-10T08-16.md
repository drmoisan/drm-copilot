# Excluded-Path Verification (Issue #543)

Timestamp: 2026-10-10T08-16
Task: [P6-T6]
Command: git diff 7bbd0b9b990737642b4eeded01a27b7c5c8348b3 -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts; git status --porcelain -- scripts/dev_tools/validate_orchestration_artifacts.py .claude .github .agents .codex extensions/drm-copilot/resources extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/src/mcp-tool-inputs.ts
EXIT_CODE: 0
Output Summary:
- `git diff <MERGE_BASE_SHA> -- <excluded paths>`: printed nothing (exit 0).
- `git status --porcelain -- <excluded paths>`: printed nothing (exit 0).
- CLI plumbing, guidance, mirrors, rules, and Jest configuration are unchanged.
- The diff is anchored to the recorded merge base 7bbd0b9b990737642b4eeded01a27b7c5c8348b3 in place of the spec's `git diff main`.
- Gitignored state (`.claude/state/`, `.claude/agent-memory`) does not appear in either output by construction.
