# Stage I Cycle 1 Pre-0010 Merged Tree

Timestamp: 2026-11-08T18-31
Command: sh SCRATCH/issue-1097-c1i-pre0010.sh (scratch index via GIT_INDEX_FILE under SCRATCH; git read-tree HEAD after P2-T3; per modify section of the 0010 patch, git merge-file with ours = HEAD text, base = text at the merge commit's first parent, theirs = the section's pre-image blob; a conflicted path whose pre-image equals its merge-base blob takes the merge commit's second-parent (origin/main) blob; each created path removed with git update-index --force-remove; git write-tree; no worktree, ref, or commit)
EXIT_CODE: 0
Output Summary:
  Pre-0010 tree id: 9955221fcfef763205dca0bd27f6cf51d2bf8d13
  Modify sections: 25; git merge-file clean: 18; conflicts: 7; findings: 0. Created paths removed: 12.
  Conflicted paths (pre-image equals the merge-base blob in each, so the origin/main blob was taken): .agents/skills/epic-run/SKILL.md, .claude/skills/epic-run/SKILL.md, .claude/agents/epic-orchestrator.md, their three bundle copies, and tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py.
  Main-added lines (merge-base diff to origin/main) present in the pre-0010 text, missing 0 in each of the 14 paths main changed: both epic-orchestrate skills 20 and 19 lines and their bundle copies; both epic-run skills 3 each and their bundle copies; epic-orchestrator.md 4 and its bundle copy; the Claude core.json 6; the Codex core.json 5; codex-epic-runtime-contracts.Tests.ps1 2; the pin file 21.
  Pin values in the pre-0010 pin file equal the SHA-256 of the pre-0010 surfaces: .claude/agents/epic-orchestrator.md f76721ce463ba06288dbd21135f572ae28cfd9036a908587e65e1e0629b55e75; .claude/skills/epic-orchestrate/SKILL.md 73d5c859007dbfe5bb0a35ad9b5444ea85fe1bf6a43571e1941952490033ed7e (main's pinned values).
  Created paths present in the tree: 0.
