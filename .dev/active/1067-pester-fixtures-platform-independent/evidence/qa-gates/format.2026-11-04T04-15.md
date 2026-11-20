# Final QA: Format (P6-T4)

Timestamp: 2026-11-04T04-15
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-format-check.ps1 (Invoke-Formatter comparison of the 22 change-set files under scripts/powershell/PoshQC/settings/pssa.settings.psd1; no file written)
EXIT_CODE: 0
Output Summary:
- FORMAT-DIFF-COUNT=0
- Loop history: the first pass (2026-11-04T04-14) printed FORMAT-DIFF-COUNT=0 and P6-T5 then reported 27 PSAvoidUsingPositionalParameters findings (Information) for `Join-Path` calls with three or more positional arguments added in Phases 1 to 5. Those calls were rewritten to `Join-Path -Path ... -ChildPath ... -AdditionalChildPath ...` in seven test files, and the loop restarted here.
