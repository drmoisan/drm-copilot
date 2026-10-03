# r3 P0-T7 baseline inventories (issue #824)

Timestamp: 2026-10-03T18-47
Command: pwsh -NoProfile -File "SCRATCH/steps/r3-p0-t7.ps1" -Worktree "WORKTREE" ((1) -CommandWord call-site inventory; (2) Test-CommandLineRawContainment locations; (3) & "$Scratch/phrase-scan.ps1" -Root @('.claude/hooks', '.codex/hooks', 'extensions/drm-copilot/resources'); (4) eight token counts; VERDICT)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-47
CALL-SITES=37 CALL-FILES=13
hook-command-invocation.ps1:96   (.claude/hooks)
hook-command-invocation.ps1:493  (.claude/hooks)
hook-command-invocation.ps1:96   (.codex/hooks)
hook-command-invocation.ps1:493  (.codex/hooks)
FILES-SCANNED=194 HITS=0
PHRASE-SCAN-EXIT=0
COUNTS=1,0,0,0,0,0,0,0
Four containment locations: the definition (line 96) and the Test-CommandLineMention caller (line 493) in hook-command-invocation.ps1 on each surface.
