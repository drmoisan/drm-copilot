# Bundled-Copy Byte Parity (issue #413)

Timestamp: 2026-07-25T17-16

Covers plan tasks [P3-T3] (hand resync) and [P3-T4] (deterministic parity verification).

## [P3-T3] Resync mechanism

Command: `pwsh -NoLogo -NoProfile -Command "Copy-Item -Force .claude/hooks/validate-orchestrator-output.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1"`

No regeneration script exists for this pushed-down payload; `Copy-Item -Force` is the sync
mechanism specified by the plan. Completed with no output and no error.

## [P3-T4] Deterministic parity verification

Command:

```text
pwsh -NoLogo -NoProfile -Command '$a = (Get-FileHash .claude/hooks/validate-orchestrator-output.ps1 -Algorithm SHA256).Hash; $b = (Get-FileHash extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1 -Algorithm SHA256).Hash; Write-Output "repo=$a"; Write-Output "bundled=$b"; Write-Output "equal=$($a -eq $b)"'
```

Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`

EXIT_CODE: 0

Output Summary:

```text
repo=5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B
bundled=5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B
equal=True
```

- Repo copy SHA256: `5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B`
- Bundled copy SHA256: `5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B`
- `equal=True` — the two files are byte-identical after the fix, including the corrected
  `.DESCRIPTION` docstring, the corrected inline decision comment, and the
  `$hasErrors = ($exitCode -ne 0)` decision line.

Verdict: byte parity achieved. The independent pytest gate is recorded in
`parity-pytest.2026-07-25T17-16.md` ([P3-T5]).
