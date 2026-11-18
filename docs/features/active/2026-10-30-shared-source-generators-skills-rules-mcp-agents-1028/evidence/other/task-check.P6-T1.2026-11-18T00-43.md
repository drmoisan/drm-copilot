# Task Check — [P6-T1]

Timestamp: 2026-11-18T00-43
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-matrixupkeep.ps1 -Write (an in-place text edit); sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-matrixdiff.ps1 -OldFile SCRATCH/issue-1028-matrix-head.json; sh SCRATCH/issue-1028-gen.sh all check; sh SCRATCH/issue-1028-retry.sh pester -TestPath tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1 tests/scripts/harness/HarnessParityMatrix.Tests.ps1 tests/scripts/harness-generation
EXIT_CODE: 0
Output Summary: 160 of 655 entries changed, and the entry order is unchanged.
- **144 selected entries.** Each of these entries now has a source path in `generated_from` and `generator` `harness-generation/<surface>`, inserted directly after `generated_from` in child 1's field order:
  - 54 `claude` skills: `generated_from` was already `.agents/skills/<name>/SKILL.md`, and `generator` was added.
  - 38 path-scoped rules: `scripts/harness-generation/sources/rules/<stem>.json`.
  - 2 MCP servers: `scripts/harness-generation/sources/mcp-servers.json`.
  - 50 agents: `scripts/harness-generation/sources/agents/<name>.json`.
- **16 `codex:skill:<rule>` entries.** These are for the generated Codex rule-skills:
  - Each changed from `native` to `generated`.
  - Each now has `target_paths` (`.agents/skills/<rule>/SKILL.md`), `generated_from` (its rule source), `generator` `harness-generation/rules`, `owner_child` 3 and `decision_ref` `#1028:spec.md#owner-decisions`.
  - The existing `decision_status` and `notes` values are kept, because the task does not name them.

No `id` changed and no entry was added. The `native` skill entries of [P3-T2] and the agent entries of [P5-T1] were not touched. The matrix has 160 `generator` fields. Its 50 remaining `pending-source:` values are the Codex agent variants with `owner_child` null, which stay with the Python generator. `-Surface all -Check` reports "harness-generation: no drift". Pester: 263 passed and 0 failed, including `HarnessParityMatrix.RepoGate.Tests.ps1`.

Changed files: `config/harness-parity-matrix.json`.
Selection rule: `## Test Cadence (Mandatory)`. The selection is the matrix suites and the harness-generation suites, which read the matrix through the context seam.
