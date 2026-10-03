# r1 P0-T23 — bash syntax baseline of both setup-script copies

Timestamp: 2026-10-03T12-51
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t23.ps1 -Worktree WORKTREE; step script runs `$sh = (Get-Command -Name sh -CommandType Application | Select-Object -First 1).Source; $worst = 0; foreach ($f in @('.codex/codex-web-setup.sh', 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh')) { & $sh -n $f; "$f SYNTAX-EXIT=$LASTEXITCODE"; $worst = [Math]::Max($worst, $LASTEXITCODE) }; "SYNTAX-EXIT=$worst"; exit $worst`
EXIT_CODE: 0
Output Summary:
- .codex/codex-web-setup.sh SYNTAX-EXIT=0
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh SYNTAX-EXIT=0
- SYNTAX-EXIT=0
