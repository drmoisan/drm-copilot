# Task Check — [P5-T3]

Timestamp: 2026-11-18T00-02
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-agentsrc.ps1 -Write; sh SCRATCH/issue-1028-gen.sh agents check
EXIT_CODE: 0 for the source build. The read-only check exits 1, which is expected before the [P5-T4] write run.
Output Summary: The 25 source pairs render through `Get-HarnessAgentFileMap` with 0 findings, so every selected agent has a source and every source passes validation. `-Surface agents -Check` reports exactly 2 `DRIFT` lines: `.claude/agents/pr-author.md` and its bundle copy, which gain a final line feed. The other 98 rendered files equal the tree, including `.claude/agents/epic-orchestrator.md`.

Changed files: `scripts/harness-generation/sources/agents/*.json` and `*.md` (50 new data files) and `evidence/qa-gates/agent-reconciliation.2026-11-18T00-02.md`.
Selection rule: `## Test Cadence (Mandatory)`. The task adds data files only, and no test reads `sources/agents/`. [P5-T4] runs the frozen-digest, ledger and write-scope suites after the write.
