# Defects present in starting tree ([P0-T8])

Timestamp: 2026-10-08T17-31
Command: grep -c -F "CheckpointReader 'artifacts/orchestration" .codex/hooks/enforce-completion-consistency.ps1 ; grep -c -F "onDiskText.Replace" .claude/hooks/enforce-completion-consistency.ps1 ; grep -c -F "onDiskText.Replace" .codex/hooks/enforce-completion-consistency.ps1 ; grep -c -F "are allowed by this hook" .codex/hooks/enforce-completion-consistency.ps1
EXIT_CODE: 0
Output Summary: printed 1, 1, 1, 1; all four defect literals are present.

REGION_STATE: literal-present
