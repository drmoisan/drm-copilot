# Fail-Before Exception Dossier — remediation cycle 1 (issue #630)

Timestamp: 2026-09-07T15-00
Task: [P0-T9]

Command: `git grep -n -E "MERGED_CONTENT_NEUTRAL|MERGED_EQUIVALENT|HAS_UNIQUE_RESIDUALS" -- tests/shell/test_cleanup_worktrees_detached.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

## Absence-of-test proof (reproduced verbatim)

The command printed nothing and exited 1. `git grep` exits 1 with empty stdout when the pattern
matches no line in any searched file, so the empty result is the proof that none of the three state
tokens `MERGED_CONTENT_NEUTRAL`, `MERGED_EQUIVALENT`, or `HAS_UNIQUE_RESIDUALS` is asserted anywhere
in the detached suite before this cycle's edits.

```
```

(The fenced block above is empty because the command produced no output.)

WhyFailingRunImpossible: R1 and R2 add coverage over behavior that is already correct, so there is
no defect for a new case to be red against and no deterministically failing run exists. The
remediation inputs state this directly: `scripts/bash/cleanup_worktrees_detached_lib.sh` "is
functionally correct as written; the finding is that its state space is under-tested, not that it is
wrong." Each new case passes as soon as its checked-in fixture directory exists, so no task in this
cycle carries the `[expect-fail]` tag.

SearchScope:
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/regression-testing/`
- `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/evidence/`
- `tests/shell/test_cleanup_worktrees_detached.bats` (for the absence-of-test proof itself)

SearchPatterns:
- `fail-before-exception.*.md`
- `MERGED_CONTENT_NEUTRAL|MERGED_EQUIVALENT|HAS_UNIQUE_RESIDUALS`

SearchResult: none. No failing run artifact exists for this cycle, and none can exist for the reason
stated above. This dossier stands in its place.

Output Summary: the three delete-eligible and non-eligible state tokens this cycle adds coverage for
are absent from the detached suite at cycle entry; the search matched nothing and exited 1, which is
the expected exit code for an empty `git grep` result.
