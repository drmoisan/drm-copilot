# Nested Agent Worktree Exclusion

Timestamp: 2026-11-06T17-54
Command: poetry run python SCRATCH/issue-1019-nested.py
EXIT_CODE: 0
Output Summary: Read-only evaluation of the repository-relative filter with the main checkout as the repository root, which holds nested agent worktrees under `.claude/worktrees/`. 486 copies matched the glob, 480 of them inside nested agent worktrees, and the filter kept exactly 6: the three customization roots and the three `extensions/drm-copilot/resources/` bundle mirrors. Nested agent worktrees therefore stay excluded (AC2).
