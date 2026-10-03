# P0-T7 Baseline inventories (AC-2, AC-22, call sites)

Timestamp: 2026-10-03T09-38
Command: Select-String 'Test-CommandLineRawContainment' over .claude/hooks/*.ps1, .codex/hooks/*.ps1; & "SCRATCH/phrase-scan.ps1" -Root @('.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources'); $LASTEXITCODE; (Select-String "-CommandWord '").Count; unique-path count
EXIT_CODE: 0
Output Summary:
- Containment locations (6): hook-command-invocation.ps1:92, :203, :482 (Claude root); hook-command-invocation.ps1:92, :203, :482 (Codex root)
- Phrase scan: FILES-SCANNED=188 HITS=4; exit 0
  - HIT: .claude\hooks\hook-command-invocation.ps1
  - HIT: .codex\hooks\hook-command-invocation.ps1
  - HIT: extensions\drm-copilot\resources\claude-customizations\.claude\hooks\hook-command-invocation.ps1
  - HIT: extensions\drm-copilot\resources\codex-and-agents-customizations\.codex\hooks\hook-command-invocation.ps1
- "-CommandWord '" call-site count: 34; distinct files: 13
- Result: PASS
