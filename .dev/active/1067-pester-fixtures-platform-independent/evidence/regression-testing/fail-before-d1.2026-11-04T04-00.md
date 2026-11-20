# D1 Fail-Before (P1-T2)

Timestamp: 2026-11-04T04-00
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/activate.Tests.ps1 -Report 'renders a descendant prompt from the venv parent (light background)','renders a descendant prompt with the platform directory separator'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: P1-T1 test changes applied; `scripts/dev-tools/activate.ps1` unchanged (literal backslash in the descendant test).
- TOTAL Tests=54 Passed=49 Failed=5 Skipped=0 NotRun=0
- FILE tests/scripts/dev-tools/activate.Tests.ps1 tests=54 failed=5
- RESULT Get-VenvAwarePrompt (prompt decision used by the shim).renders a descendant prompt from the venv parent (light background) Failed
- RESULT Get-RepoRelativePrompt (pure logic).renders a descendant prompt with the platform directory separator Failed
- Representative message: Expected '(mix-calculator)/docs> ' but was '(mix-calculator) /activate-root/mix-calculator/docs> ' (the outside-tree form for a location inside the venv root).
- The other three failures are the descendant cases of the same defect: 'renders a one-level descendant with a leading directory separator', 'renders deeper nesting with the full relative subpath', 'compares paths case-insensitively for the descendant case'.
