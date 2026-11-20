# Scratch Script Smoke Check (#841, P0-T6)

Timestamp: 2026-10-10T09-09
Command: git grep -c "" -- CLAUDE.md
EXIT_CODE: 0
Output Summary: CLAUDE.md LineCount=56 (raw output `CLAUDE.md:56`). Substitute route operational.

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below

The operator prohibited creating or running the Appendix A scratch scripts and prohibited running any sh/bash/pwsh command or wrapper script. None of the eight scripts was created. The plan's eight script file names, recorded as required by the acceptance text:

1. A1 `run-ps.sh` (not created)
2. A2 `pester-counts.ps1` (not created)
3. A3 `pester-coverage.ps1` (not created)
4. A4 `pair-hashes.ps1` (not created)
5. A5 `pssa-count.ps1` (not created)
6. A6 `ps-format-check.ps1` (not created)
7. A7 `line-counts.ps1` (not created)
8. A8 `changed-line-coverage.ps1` (not created)

Fixed operator substitutes (applied in every affected task):

- A7 line counts: `git grep -c "" -- <path>` (tracked) or `git grep --untracked -c "" -- <path>` (untracked); recorded as `<path> LineCount=<n>`.
- A4 pair hashes: `git hash-object <source> <mirror>` per Appendix G1 pair; recorded per pair plus `PAIR-SUMMARY pairs=<n> unequal=<n>`.
- A6 format check: `git status --porcelain` before; `mcp__drm-copilot__run_poshqc_format` with scan_folders [".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]; `git status --porcelain` and `git diff --stat` after; ChangedCount = files modified by the call. At baseline, modified pre-existing files are restored with `git checkout -- <path>`.
- A5 PSSA: `mcp__drm-copilot__run_poshqc_analyze` with the same scan_folders; DiagnosticCount=0 when it returns normally, N from "PSScriptAnalyzer reported N issue(s)." when it raises.
- A2/A3 Pester counts and coverage: `mcp__drm-copilot__run_poshqc_test` (disposition only), then read `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` (JaCoCo; LINE counter of `Invoke-CiGateParser.ps1`).
- A8 changed-lines coverage: `git diff -U0 <BASE_SHA> -- .claude/lib/ci-gate/Invoke-CiGateParser.ps1` hunk ranges intersected with coverage XML line elements.

Deviation: the plan's literal command `sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 CLAUDE.md` was not run; the A7 substitute above produced the equivalent `CLAUDE.md LineCount=` line.
