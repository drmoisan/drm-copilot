# Scope Check

Timestamp: 2026-11-07T03-12
Command: pwsh -File SCRATCH/issue-1094-scope.ps1, which runs git diff --name-only and a line diff from the merge base of origin/main and HEAD, git status --porcelain, and the evidence scan, and exits non-zero on any match
EXIT_CODE: 0
Output Summary: CHANGED=246 PORCELAIN=0 SCOPE_HITS=0 ADDED_LINES=1602 DEFERRED_HITS=0 EVIDENCE_FILES=16 EVIDENCE_HITS=0 
