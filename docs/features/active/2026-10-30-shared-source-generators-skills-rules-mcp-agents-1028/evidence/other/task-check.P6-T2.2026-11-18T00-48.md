# Task Check — [P6-T2]

Timestamp: 2026-11-18T00-48
Command: sh SCRATCH/issue-1028-run.sh SCRATCH/issue-1028-psstatic.ps1 -Mode both -FolderList 'tests/scripts/harness-generation'; sh SCRATCH/issue-1028-retry.sh pester -TestPath tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1
EXIT_CODE: 0
Output Summary: Format: 8 files, 0 would change. PSScriptAnalyzer: 0 findings. The gate passes on the working tree: 3 tests, 3 passed, 0 failed.
- `reports no drift for any generated target in the working tree`: `Get-HarnessRepositoryDrift` runs against the working tree. On failure it puts every drifted path in the `-Because` message.
- `records a source path and a generator for every selected entry whose source exists`: no selected entry holds `pending-source:`, and each one whose source exists has `generator`.
- `names the drifted path when a target differs from its source`: an injected reader returns `{}` for `.mcp.json`, and the finding list and drift report both name that path.

The suite starts no process, reads no git history, and writes no file: it reads through `New-HarnessGenerationContext`.

Changed files: `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` (new).
Selection rule: `## Test Cadence (Mandatory)`; the new suite itself.
