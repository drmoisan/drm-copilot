# Spec old token count

Timestamp: 2026-10-07T22-00
Command: git grep -cF 'probe maps to' -- docs/features/completed/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md (equivalent of grep -cF; no plain grep available in the Bash tool)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: printed count is 0 (git grep -c prints nothing on zero matches; exit 1 observed via echo of the exit status). Baseline count in P0-T5 was 2, so both contradicting passages are gone.
