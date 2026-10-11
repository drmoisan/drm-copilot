# Longest-Match Search After the Change

Timestamp: 2026-10-08T19-29
Command: grep -rnE 'Sort-Object[^|]*Length' --include='*.ps1' --include='*.psm1' --exclude-dir=worktrees --exclude-dir=state .claude .codex extensions/drm-copilot/resources
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No output; grep exit 1. The baseline (evidence/baseline/sort-length-search.2026-10-08T17-32.md) recorded 10 lines; no length-ordered feature-folder selection remains under .claude, .codex, or the bundled resources.
