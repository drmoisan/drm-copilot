# AC24 Follow-Up Candidates (P7-T6)

Timestamp: 2026-09-29T17-58
Command: git grep -n --untracked -F "Follow-up issue:" -- docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md
EXIT_CODE: 0

Output Summary:
- Exit code 0; exactly 2 output lines:
  - spec.md:279: Follow-up issue: Python `.gitignore` managed-block merge. ... Evidence: research artifact, Python has no counterpart to the TypeScript `.gitignore` managed-block merge.
  - spec.md:280: Follow-up issue: Python CLI publishes gitignored `.claude` subtrees from a main checkout. ... Evidence: research artifact, `push_down_copilot_customizations_filesystem.py:99-107` lists every file with no ignore filter.
- One line contains `.gitignore`, the other contains `gitignored`; each contains `Evidence:`.
- Filing the two issues is performed by the epic orchestration session through the MCP promotion path (not an execution task of this plan).
