# P4-T2 New module purity and self-containment

Timestamp: 2026-09-30T07-39

Note on exit codes: the shell tool in this environment reports no exit code for a passing command and an empty result for a non-matching `git grep`; a wrapped `echo $?` is refused by the worktree isolation guard. Exit codes for the three absence checks are therefore the documented `git grep` semantics for no match (1), corroborated by the empty output. The presence check printed a count line, which is only produced on a match (exit 0).

## Command 1 (presence anchor)
Command: git grep --no-index -c -F -e "BUG_PROMOTION_ENTRY_TOOL" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 0
Output Summary: `extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts:2` (count 2, at least 1; the path resolves, so the absence checks cannot pass vacuously).

## Command 2
Command: git grep --no-index -c -F -e "orchestrator-state-routing" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 1
Output Summary: empty output; the module does not reference the routing module.

## Command 3
Command: git grep --no-index -c -F -e "node:" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 1
Output Summary: empty output; no `node:` import.

## Command 4
Command: git grep --no-index -c -F -e "import {" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts
EXIT_CODE: 1
Output Summary: empty output; the module imports nothing.
