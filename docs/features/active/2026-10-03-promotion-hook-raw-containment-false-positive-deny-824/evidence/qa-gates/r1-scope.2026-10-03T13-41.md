# r1 P8-T17 — scope check

Timestamp: 2026-10-03T13-41
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p8-t17.ps1 -Worktree WORKTREE (A0; the BASE_SHA-anchored `git diff --name-only` plus `git ls-files --others --exclude-standard` minus SCRATCH/pre-untracked.txt, both excluding FEATURE and .claude/agent-memory; the porcelain status of .claude/hooks, .codex/hooks, and tests/scripts/dev_tools; SCOPE-ARRAY; the Compare-Object and status-outside lines; the P8-T17 VERDICT line)
EXIT_CODE: 0
Output Summary:
- CHANGED-COUNT=59
- SCOPE-ARRAY-COUNT=59
- SCOPE-DIFFERENCES=0 STATUS-OUTSIDE=0 (the changed set equals SCOPE-PATHS (D11) exactly; the status lines name only SCOPE-PATHS)
- Status lines: ` M` for CLAUDE-RAW, CODEX-RAW, EPIC-GATE, PAR-GATE, CODEX-GATE, FR-HOOK, and PYA; `??` for FR-THRESH and PYG.
