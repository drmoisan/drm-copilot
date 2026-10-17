# AC-9 CI Evidence: Invoke-CiGateParser.ps1 line coverage

Timestamp: 2026-10-12T22-55
Command: gh run download 38317374627 --repo drmoisan/drm-copilot -n poshqc-test-results -D <session scratchpad>/issue-899-poshqc
EXIT_CODE: 0
Output Summary:
- PR: #923 (https://github.com/drmoisan/drm-copilot/pull/923)
- Workflow: CI, run id 38317374627, conclusion success
- Head SHA tested: 49c6666262bdeba2e110571dbe763e681866bbe0 (equal to the PR head at the time of the run)
- Job: poshqc / PowerShell QC (pass, 18m14s)
- Artifact: poshqc-test-results, file powershell-coverage.xml
- Package: name ending `.claude/lib/ci-gate`; sourcefile `Invoke-CiGateParser.ps1`
- Per-file counters:
  - LINE: missed="0" covered="46"
  - INSTRUCTION: missed="0" covered="55"
  - METHOD: missed="0" covered="4"
  - CLASS: missed="0" covered="1"
- Per-line entries with a non-zero missed-instruction count: none
- Result: zero missed lines in `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (46/46, 100.00%). Baseline reference was 45/46 with line 338 missed (97.83%); line 338, the default `$NowProvider` delegate, is now covered.
- AC-9: PASS
