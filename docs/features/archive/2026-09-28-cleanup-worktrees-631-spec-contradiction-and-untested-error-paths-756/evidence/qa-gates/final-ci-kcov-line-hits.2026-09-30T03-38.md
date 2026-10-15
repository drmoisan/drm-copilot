# Final CI kcov line hits (P2-T14)

Timestamp: 2026-10-08T02:17:00Z
Command: Grep for the statements in .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh (line numbers L: rc=2 -> 425; return "$scanrc" -> 292; return "$srrc" -> 290; rc=$srrc -> 296; rc=$orc -> 300; rc=$lrc -> 304), then Grep of those line numbers in artifacts/pester/kcov-final-756/kcov-merged/cleanup_worktrees_report_records_lib.sh.4cc4cdda.js
EXIT_CODE: 0
Output Summary: Deviation: the kcov cov.xml of this run has an empty <class> element with no <line number=... hits=...> rows, so the awk derivation on cov.xml yields nothing; the per-line rows come from the kcov per-file .js data in the same artifact. Rows (all hits 1):
- 290 return "$srrc" lineCov hits="1"
- 292 return "$scanrc" lineCov hits="1"
- 296 rc=$srrc lineCov hits="1"
- 300 rc=$orc lineCov hits="1"
- 304 rc=$lrc lineCov hits="1"
- 425 rc=2 lineCov hits="1"
Six of six statements have hits greater than 0.
