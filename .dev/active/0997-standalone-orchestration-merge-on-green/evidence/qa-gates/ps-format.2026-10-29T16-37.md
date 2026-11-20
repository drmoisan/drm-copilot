# PowerShell Format (issue #997)

Timestamp: 2026-10-29T16-37
Command: sh SCRATCH/issue-997-static.sh (format step: SCRATCH/issue-997-format.ps1 imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat over the nine files below, comparing SHA-256 before and after; git status --porcelain captured before and after)
EXIT_CODE: 0
Output Summary: FORMAT_FILES=9; FORMAT_CHANGED_COUNT: 0; each file reported "Already formatted"; PORCELAIN_UNCHANGED.

Files: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1`.

Loop history: the first pass formatted nothing but the analyzer reported four findings in the new suites; the suites were fixed and the loop restarted from this step. This artifact records the passing run.
