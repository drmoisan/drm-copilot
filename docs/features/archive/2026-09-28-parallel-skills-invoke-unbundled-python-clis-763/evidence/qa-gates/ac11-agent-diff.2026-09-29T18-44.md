# AC11 Agent Diff (P6-T7)

Timestamp: 2026-09-29T18-44
Command: git diff -U0 12db46245ba7683b5d6ccb676312a4b22a39b0ce -- .claude/agents/parallel-orchestrator.md ; sh SCRATCH/surface-token-count.sh
EXIT_CODE: 0
Output Summary:
- Hunks: `@@ -20,0 +21 @@ tools:`, `@@ -21,0 +23 @@ tools:`, `@@ -97,6 +99,10 @@` (prose).
- Added lines beginning `  - "Bash(` are exactly the two B24a entries at positions 8 and 10:
  - `  - "Bash(bash .claude/lib/bash/abandon-parallel-item.sh*)"` (position 8)
  - `  - "Bash(pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*)"` (position 10)
- No removed line begins `  - "Bash(`, and no removed line contains `Bash(poetry run python -m *)`.
  The only removed lines are the six prose lines 97-102 at BASE_SHA, replaced by the B24b paragraph.
- A20:
  COUNT T3 .claude/agents/parallel-orchestrator.md 1
  COUNT T4 .claude/agents/parallel-orchestrator.md 1
  COUNT T5 .claude/agents/parallel-orchestrator.md 1
  (the bundle mirror carries the same three counts, 1 each)

Diff anchor: BASE_SHA per DV2.
