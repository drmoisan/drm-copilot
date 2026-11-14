# Ledger Region Inventory (remediation cycle 1, P0-T2)

Timestamp: 2026-11-14T12-51
Command: pwsh -NoProfile -File SCRATCH/issue-1158-ledger-inventory.ps1 -Root <worktree>; pwsh -NoProfile -File SCRATCH/issue-1158-region-search.ps1 -Root <worktree>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (through SCRATCH/issue-1158-run-suite.sh), counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: Four planned edit sites fall inside recorded regions: the executor Toolchain Commands bullets, python-qa-gate step 4, and the python-atomic-executor step 4 command are inside entry 0001's stored patch; the brief task-check bullet and the atomic-plan-contract Task check bullet are inside entry 0011 blocks; parallel-gate-wording.Tests.ps1 is inside the 0001 creation hunk. Every other planned edit is outside every region. The launcher pester suite (unscoped, because the scoped entry does not exist before P1-T1) exited 0 with 8 workers: 26384 tests, 0 failures, 0 errors, 18 skipped; ProcessReductionChain.Ledger.Tests.ps1 5 passed, ProcessReductionLedger.Index.Tests.ps1 15 passed.

## Ledger Test Files (launcher pester suite, 868.83 s wall clock)

| File | Test cases | Failures |
|---|---|---|
| tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | 5 | 0 |
| tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 | 15 | 0 |

The run was the whole launcher pester suite, the only launcher route before P1-T1 adds -TestPath; it is not gate evidence for this cycle.

## Search

For each file, every entry of `docs/engineering/process-reductions/` whose `## Files Changed` section names the path, whose `### Revert Block:` heading names it, or whose stored patch carries a `diff --git a/<path> b/<path>` header was listed (SCRATCH/issue-1158-ledger-inventory.ps1). Each planned edit's lines were then searched in every block fence and every stored-patch line, with the block heading, fence label, patch section, and hunk header recorded (SCRATCH/issue-1158-region-search.ps1). Re-running both scripts on the same tree yields the same set.

## Regions and Verdicts

| File (and copies) | Entries naming it | Region of the planned edit | Verdict |
|---|---|---|---|
| `scripts/powershell/PoshQC/PoshQC.Parallel.psm1`, `scripts/powershell/PoshQC/README.md` (P1-T1) | none | none | outside |
| `.claude/agents/atomic-executor.md` (P2-T1) | 0001 (patch), 0003 (1 block), 0006 (patch), 0009 (patch), 0011 (2 blocks) | 0001 stored-patch hunk `@@ -77,9 +77,9 @@ For each task:`: the `## Toolchain Commands` Python and PowerShell bullets are its `+` lines; no block of 0003 or 0011 and no hunk of 0006 or 0009 holds either bullet | inside 0001 |
| `.codex/agents/atomic-executor.toml` and `atomic-executor-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` (P2-T1) | 0001 (patch), 0003 (base: 1 block), 0006 (patch), 0009 (patch), 0011 (base: 2 blocks), 0012 (base: 1 block) | 0001 stored-patch hunk `@@ -89,9 +89,9 @@ For each task:` in each of the six sections: the same two bullets are `+` lines; the 0003, 0011, and 0012 blocks hold neither bullet | inside 0001 |
| `.claude/skills/python-qa-gate/SKILL.md`, `.agents/skills/python-qa-gate/SKILL.md` (P2-T2) | 0001 (patch), 0006 (patch), 0011 (1 block each), 0012 (1 block each) | 0001 stored-patch hunk `@@ -30,39 +30,38 @@ Run the full toolchain`: step 4 of `## Toolchain Execution Sequence` is a `+` line; the 0006 hunks and the 0011 and 0012 blocks do not hold it | inside 0001 |
| `.github/agents/python-atomic-executor.agent.md` (P2-T2) | 0001 (patch), 0005 (2 blocks), 0006 (patch), 0011 (3 blocks), 0012 (1 block) | 0001 stored-patch hunk `@@ -263,7 +263,7 @@ Required toolchain for Python tasks:`: the step 4 test command of `### 7.1 Python policy and toolchain gates` is a `+` line; no other region holds it | inside 0001 |
| `.claude/skills/test-execution-policy/SKILL.md` (P2-T3) | none | none | outside |
| `.claude/skills/execution-environment/SKILL.md` (P2-T4), task-check bullet of `## PowerShell Route and PoshQC MCP Limits` | 0001 (2 blocks, patch), 0002 (5 blocks), 0003 (2 blocks), 0006 (2 blocks, patch), 0011 (4 blocks), 0012 (1 block) | 0011 block whose `Current` starts with the `Invoke-Pester` without `-EnableExit` bullet and holds the task-check bullet; the 0001 hunk `@@ -39,9 +39,10 @@` sees the tree after 0011 is reverted, where the bullet is absent | inside 0011 |
| same file, new bullet of `## Test Isolation Checks` | same | placed at the end of the section, after the #1158 launcher bullet: the 0011 block ends at `Serial tasks remain`, the 0001 block ends at `The parallel gates govern`, and the 0001 hunk `@@ -148,18 +151,20 @@` ends at the `Invoke-PoshQCLeakScan` context line | outside |
| `.claude/skills/atomic-plan-contract/SKILL.md`, `.agents/...`, `.github/...` (P2-T5) | 0001, 0003, 0004, 0005, 0006, 0008, 0009, 0011, 0012 | 0011 block whose `Current` is the whole `## Test Cadence (Mandatory)` section (one per source); the 0012 block is the lane-exclusion sentence elsewhere; the older patches see the tree after 0011 is reverted, where the section is absent | inside 0011 |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` (P2-T1 to P2-T3) | 0001 (patch: creation hunk), 0006 (patch hunks), 0012 (Files Changed only) | the 0001 creation hunk holds the whole pre-0006 file, so every edit is inside it; the 0006 hunks are regenerated only when an edit falls inside one | inside 0001 (and 0006 where a hunk covers the edit) |
| `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` (P2-T4, P2-T5) | 0011 (Files Changed only; no block, no patch) | none | outside |
| `tests/scripts/claude-skills/test-execution-policy/Invoke-PesterSuite.Tests.ps1`, `tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1` (P1-T2) | none | none | outside |
| `<FEATURE>/user-story.md`, `<FEATURE>/spec.md` (P2-T6) | none | none | outside |

Bundle copies and generated Codex variants carry the same stored-patch sections as their sources in 0001, 0006, and 0009; each section is regenerated with its source's section.

## Copy Classification (Get-FileHash SHA256, first 12 hex characters)

| Copy set | Classification |
|---|---|
| `PoshQC.Parallel.psm1` and `README.md` with their `extensions/drm-copilot/resources/powershell/PoshQC/` copies | byte-identical pairs (3E84CE31A870; 5D2E4E67A9D6) |
| `.claude/agents/atomic-executor.md` and its bundle copy | byte-identical (A61E8BF19856) |
| each `.codex/agents/atomic-executor*.toml` and its bundle copy | byte-identical pairs (84EB0C87E24F, D70DCC57FA2B, B8998F44091B, 95E7777D58FA, 637E72ED90E3, 99BFA4015B5D) |
| `python-qa-gate` `.claude` and `.agents` with bundle copies | two byte-identical pairs (79BAC9E265F1; 51FD6B001083); the two sources differ (launcher path) |
| `.github/agents/python-atomic-executor.agent.md` and its bundle copy | byte-identical (FF9A4229F755) |
| `test-execution-policy` six copies | all byte-identical (6C3DAB0720D2) |
| `execution-environment` six copies | all byte-identical (3EE2062C4B33) |
| `atomic-plan-contract` six copies | three byte-identical pairs (`.claude` 67BECC41CF06; `.agents` B7740D7A2D4A; `.github` 9680218E11B4); the three sources differ |
