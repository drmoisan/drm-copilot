# Baseline — Bundle vs Repo Pre-State Diff (Issue #207, Remediation Pass 1)

Timestamp: 2026-06-19T19-15

Command:
- test -f extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
- diff .claude/settings.json extensions/drm-copilot/resources/claude-customizations/.claude/settings.json

EXIT_CODE: 1 (diff reports differences; hook file absent)

Output Summary:
Two out-of-sync paths identified:

1. B1 — Hook file ABSENT from bundle:
   extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1
   does not exist. Repo source exists at
   .claude/hooks/enforce-completion-consistency.ps1 (274 lines).

2. B2 — settings.json differs:
   The bundled settings.json is missing the new hook registration in the Write|Edit
   PreToolUse matcher block. diff output:

   118,121d117
   <           },
   <           {
   <             "type": "command",
   <             "command": "pwsh -NoProfile -File .claude/hooks/enforce-completion-consistency.ps1"

   The repo .claude/settings.json registers enforce-completion-consistency.ps1 as the
   last hook in the Write|Edit matcher; the bundled copy ends that block at
   enforce-checkpoint-monotonic.ps1.
