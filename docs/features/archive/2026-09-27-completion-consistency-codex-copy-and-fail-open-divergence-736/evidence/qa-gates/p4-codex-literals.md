# Codex path-fix and header literal checks ([P4-T5])

Timestamp: 2026-10-08T18-02
Command: grep -c -F "CheckpointReader 'artifacts/orchestration" .codex/hooks/enforce-completion-consistency.ps1 ; grep -c -F "are allowed by this hook" .codex/hooks/enforce-completion-consistency.ps1
EXIT_CODE: 1
Output Summary: both commands print 0 (they printed 1 and 1 in [P0-T8]); grep exits 1 on a zero count, and the printed 0 is the gate value.
