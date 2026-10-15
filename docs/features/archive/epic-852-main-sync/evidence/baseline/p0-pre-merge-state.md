# Phase 0 Pre-Merge State

Timestamp: 2026-10-10T23-43
Task: [P0-T4]
Command: git rev-parse HEAD ; git status --porcelain ; git merge-base --is-ancestor 8ee1b76e64c02ce5e399baac1fc201efad819d69 HEAD ; sh <SCRATCHPAD>/r.sh rhash <pairs> (Get-Content line count and Get-FileHash -Algorithm SHA256)
EXIT_CODE: 0

## git rev-parse HEAD

```text
932ddbef1b5ec5edb1bc77f88066125d3155cc40
```

## git status --porcelain

```text
 M docs/features/active/epic-852-main-sync/plan.2026-10-10T22-52.md
?? docs/features/active/epic-852-main-sync/evidence/
```

## Ancestry check

Command: git merge-base --is-ancestor 8ee1b76e64c02ce5e399baac1fc201efad819d69 HEAD
ANCESTRY_EXIT_CODE: 0

## Line counts and SHA256

```text
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | 465
HASH: .claude/hooks/validate-feature-review-coverage.ps1 | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | 465
HASH: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0
MIRROR: .claude/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-feature-review-coverage.ps1 | equal | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0 | FF063D8080D2A911D27E77113CF9CFD414F0262D9B7B7E2DAC4D9ED9414447B0
HASH: .codex/hooks/validate-feature-review-coverage.ps1 | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E
HASH: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E
MIRROR: .codex/hooks/validate-feature-review-coverage.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-feature-review-coverage.ps1 | equal | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E | 278F92FE329107E90A7B8792FEF191FC7B302BFBD7DF9C4168FD3F1AF0A42E7E
```

Output Summary: HEAD 932ddbef1; ancestry check exit 0; Claude hook pair equal (465 lines each); Codex hook pair equal (304 lines each).
