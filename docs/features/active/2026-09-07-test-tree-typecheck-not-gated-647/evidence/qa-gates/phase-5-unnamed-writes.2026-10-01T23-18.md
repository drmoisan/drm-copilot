# Phase 5 unnamed-write check (#647, rule 8)

Timestamp: 2026-10-01T23-18
Command: git diff --name-only 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/test ; git status --porcelain -- extensions/drm-copilot/test ; grep -vxF -f <phase-1..5 lists with trailing "(" removed> <name list>
EXIT_CODE: 1
ExpectedExitCode: 1

Name list: 39 paths (Phases 1 to 5 test-tree files that were modified; confirm-only files with no edit do not appear).
Porcelain: 3 ` M` entries (the Phase 5 files not yet committed); no `??` path.
Paths not named in phase-1-files.txt to phase-5-files.txt: (none; grep exit 1)

Output Summary: every changed test-tree path is named in a Phase 1 to 5 list; no unnamed write.
