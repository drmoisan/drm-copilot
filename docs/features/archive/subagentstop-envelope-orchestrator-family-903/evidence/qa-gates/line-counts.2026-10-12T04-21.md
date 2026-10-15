# AC-17 Line Counts, Static Re-run ([P7-T8] re-run of [P6-T9])

Timestamp: 2026-10-12T04-21
Command: git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD ; git status --porcelain ; sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/line-counts.ps1 <the 32 listed paths that do not end in .md>
EXIT_CODE: 0
Output Summary: LINECOUNT-SUMMARY OverLimitCount=0; the diff listing (HEAD 4f2355764) contains every S-PROD-6, S-MIRROR-6, S-TEST-MOD-11, and S-TEST-NEW-8 path; git status --porcelain lists only feature-folder paths.

The 32 non-.md paths and their counts are unchanged from evidence/qa-gates/line-counts.2026-10-12T04-09.md (no non-.md file changed after that run; largest: validate-orchestrator-output.Tests.ps1 454, FailClosed 461, validate-planner-output.ps1 440).
LINECOUNT-SUMMARY OverLimitCount=0
