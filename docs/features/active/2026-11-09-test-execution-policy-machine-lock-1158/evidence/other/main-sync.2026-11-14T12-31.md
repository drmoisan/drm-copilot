# Main Sync and Anchor Check (remediation cycle 1, P0-T1)

Timestamp: 2026-11-14T12-31
Command: git -C <worktree> fetch origin; git -C <worktree> rev-list --count HEAD..origin/main
EXIT_CODE: 0
Output Summary: origin/main has not advanced past the branch (0 commits behind); no merge was needed ("already current"). Every anchor below is present on the current tree; none moved.

## Merge Result

- already current: `HEAD..origin/main` count 0 after fetch; merge base of origin/main and HEAD equals origin/main.

## Anchors

| Anchor | File | Status |
|---|---|---|
| `## Toolchain Commands` | .claude/agents/atomic-executor.md | present |
| `## Toolchain Commands` | .codex/agents/atomic-executor.toml | present |
| `## Toolchain Execution Sequence` | .claude/skills/python-qa-gate/SKILL.md | present |
| `### 7.1 Python policy and toolchain gates` | .github/agents/python-atomic-executor.agent.md | present |
| `## Commands` | .claude/skills/test-execution-policy/SKILL.md | present |
| `## PowerShell Route and PoshQC MCP Limits` | .claude/skills/execution-environment/SKILL.md | present |
| `## Test Isolation Checks` | .claude/skills/execution-environment/SKILL.md | present |
| `## Test Cadence (Mandatory)` | .claude/skills/atomic-plan-contract/SKILL.md | present |
| `Invoke-PoshQCParallelTest`, `Get-PoshQCParallelShardArgument` | scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | present |
| `Resolve-PoshQCScanFolder` accepts a file path | scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1 | present (resolves any existing path inside Root; the shard `EnumerateTests` seam calls `Get-ChildItem -Recurse -Include *.Tests.ps1`, which returns a file path as itself) |
| `-ForEach` row lists | tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | present (`PGW-<Id>` rows) |
| `BRIEF` rows (`Get-TcwRow -Group 'BRIEF'`) and `$canonicalRequired` (`CANONICAL`) | tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 | present |

## Logical Sizes (wc -l; each file ends with a line terminator)

| File | Lines |
|---|---|
| scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | 469 |
| tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | 292 |
| tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 | 541 |
| tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1 | 437 |
