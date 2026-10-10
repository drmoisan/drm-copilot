# Bats Unit Suite (Local) — [P4-T11]

Timestamp: 2026-10-10T08-27
Command: npx --yes bats tests/shell/parallel_mutation_remove.bats (not run locally)
EXIT_CODE: N/A
CI-DEFERRED: yes
CI-DEFERRED-ACS: AC-8, AC-9
Reason: operator constraint prohibits local bats execution
Output Summary:
- The plan's authorized skip branch for [P4-T11] is taken under the operator constraint; no local bats process was started, so no TAP plan line or `not ok` line exists locally.
- The suite `tests/shell/parallel_mutation_remove.bats` exists (287 lines, 43 `@test` cases) and is verified from the CI bats job log on the pull request (expected TAP plan for this file's 43 cases, with no `not ok` line).
- Pre-CI literal verification: every expected stdout/stderr literal in the suite was observed by running the same argument vector through `sh .claude/lib/bash/remove-parallel-item.sh` (Phase 3 smoke and Phase 4 checks) and, for each non-usage row, cross-checked against the Python reference functions (`decide_removal`, `recolor_unstarted`, `build_remove_entry`); all matched.
- AC-8 and AC-9 are left for CI confirmation in [P9-T1].
