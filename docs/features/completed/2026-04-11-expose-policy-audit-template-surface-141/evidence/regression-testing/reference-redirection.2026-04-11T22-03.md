Timestamp: 2026-04-11T22:38:55-04:00
Command: rg -n 'docs/features/templates/policy_audit/AGENTS\.md' .agents .codex .github docs extensions/drm-copilot/resources -g '!docs/features/archive/**'
EXIT_CODE: 0
Output Summary:
- Active staged-review agent match removed: `.github/agents/staged-review.agent.md` no longer appears in the result set.
- Remaining matches are limited to documented exceptions in the active feature folder:
  - feature-requirement text in `issue.md`, `spec.md`, and `user-story.md`
  - historical evidence in `research.md`, `plan.2026-04-11T22-03.md`, and `evidence/baseline/phase0-instructions-read.2026-04-11T22-03.md`
- No remaining redirect target requires a Python or PowerShell wrapper change.
