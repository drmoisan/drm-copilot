# Phase 7 unnamed-write check (#647, rule 8)

Timestamp: 2026-10-01T23-18
Command: git diff --name-only 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot ; git status --porcelain -- extensions/drm-copilot ; grep -vxF -f <phase-1..7 lists with trailing "(" removed> <name list>
EXIT_CODE: 1
ExpectedExitCode: 1

Name list: 63 paths (2 `src/lib/codex-native-converter` files and 61 test-tree files; the 8 confirm-only files with no edit do not appear).
Phase lists union: 71 paths.
Porcelain: 12 ` M` entries (Phase 7 files not yet committed); no `??` path.
Paths not named in phase-1-files.txt to phase-7-files.txt: (none; grep exit 1)

Output Summary: every changed path is named in a phase list; 63 <= 71.
