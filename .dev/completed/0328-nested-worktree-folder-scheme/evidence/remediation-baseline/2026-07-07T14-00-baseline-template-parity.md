# Baseline — Template Parity (script vs bundled template)

Timestamp: 2026-07-07T13-46
Command: git diff --no-index scripts/dev-tools/new-claude-worktree-session.ps1 extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1
EXIT_CODE: 0

Output Summary:
- Empty diff, exit code 0. The production script and its bundled template are byte-identical at baseline (before any Phase 1 edit). Any Phase 1 change must be applied in lockstep to both files to preserve this parity.
