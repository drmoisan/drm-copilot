# r2 P0-T7 baseline inventories

Timestamp: 2026-10-03T15-51
Command: pwsh -NoProfile -File "SCRATCH/steps/r2-p0-t7.ps1" -Worktree "WORKTREE" (items 1 to 8 of P0-T7: call-site count, containment locations, A4 phrase scan, token counts, setup guard, shell-QC include pattern, workflow step and token counts, shell-QC kcov out_dir default and rm; VERDICT)
EXIT_CODE: 0
Output Summary: every inventory matches the plan's expected baseline; VERDICT passed.
- CALL-SITES=37 CALL-FILES=13
- Containment locations: hook-command-invocation.ps1:94 and hook-command-invocation.ps1:490, once per hooks root (4 lines)
- FILES-SCANNED=194 HITS=0; PHRASE-SCAN-EXIT=0
- COUNTS=0,1,2,2,1,1,1,0
- GUARD-LINES=1 SETUP-LAST-IS-GUARD=False
- INCLUDE-LINES=1 INCLUDE-HAS-CODEX=False
- WORKFLOW-STEPS=8 WORKFLOW-NEW-TOKENS=0 EXISTING-UPLOAD-PATH=1 GATE-EXISTS=False
- OUT-DIR-DEFAULT=1 RM-OUT-DIR=1

```text
TS=2026-10-03T15-51
CALL-SITES=37 CALL-FILES=13
hook-command-invocation.ps1:94
hook-command-invocation.ps1:490
hook-command-invocation.ps1:94
hook-command-invocation.ps1:490
FILES-SCANNED=194 HITS=0
PHRASE-SCAN-EXIT=0
COUNTS=0,1,2,2,1,1,1,0
GUARD-LINES=1 SETUP-LAST-IS-GUARD=False
INCLUDE-LINES=1 INCLUDE-HAS-CODEX=False
WORKFLOW-STEPS=8 WORKFLOW-NEW-TOKENS=0 EXISTING-UPLOAD-PATH=1 GATE-EXISTS=False
OUT-DIR-DEFAULT=1 RM-OUT-DIR=1
```
