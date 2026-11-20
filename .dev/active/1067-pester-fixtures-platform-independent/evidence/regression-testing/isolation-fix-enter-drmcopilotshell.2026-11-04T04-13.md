# Isolation Fix: Enter-DrmCopilotShell.Tests.ps1 (P6-T2)

Timestamp: 2026-11-04T04-13
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=9 Passed=9 Failed=0 Skipped=0 NotRun=0
- PROBE GLOBAL_PROMPT_CHANGED=False
- PROBE LEAKED_GLOBAL_FUNCTIONS=0 (before the fix, P3-T4 recorded 7)
- Change: `BeforeAll` captures the global prompt's ScriptBlock (`Function:\prompt`) before dot-sourcing the support script; `AfterEach` restores it through `Set-Item -Path Function:\global:prompt`; a new `AfterAll` removes the seven `global:` functions that `DrmCopilotPromptSupport.ps1` defines.
- Probe discrimination check: a SCRATCH-only suite that runs `Set-Item -Path Function:\global:prompt` produces `PROBE GLOBAL_PROMPT_CHANGED=True` under the same run script, so the probe detects a global prompt change. The pre-fix run (P3-T4) also reported `False`, so the prompt restore has no observed fail-before on this host; the leaked-function count is the observed fail-before/pass-after signal.
