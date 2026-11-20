# Final QC — P7-T2 lint FAILED, and the finding is load-bearing

Timestamp: 2026-09-08T03-10
Commit under test: working tree at `9b8e2266` plus the uncommitted Phase 5 and Phase 6 changes.
Run by: orchestrator (EA-4; the bash toolchain is denied to the delegated executor).

## P7-T1 formatter — PASS

Command: `shfmt -l scripts .claude/lib/bash` was not used here; the write-mode gate was run.
Command: `sh scripts/bash/shell-qc.sh format`
EXIT_CODE: 0

Before digest: `5efdb0979d14aa854522c26af387dc9de7139f3d966bb55d78dbb12f4e8b9f2d`
After digest:  `5efdb0979d14aa854522c26af387dc9de7139f3d966bb55d78dbb12f4e8b9f2d`

Digest command:
`for r in tools scripts .claude/lib/bash; do [ -d "$r" ] && find "$r" -type f -print0; done | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum`

Output Summary: the two digests are identical, so the formatter rewrote nothing. This is the
observation that can fail; `shfmt -w` exits 0 and prints nothing on both a clean and a repairing
run, so its exit code alone could not distinguish them.

## P7-T2 lint — FAIL

Command: `sh scripts/bash/shell-qc.sh check`
EXIT_CODE: 1

Output Summary: one `shellcheck` finding. No `shfmt` diff hunk.

```
In scripts/bash/cleanup-worktrees.sh line 145:
                CLEANUP_WT_CLEAR_DISPOSABLE=1
                ^-------------------------^ SC2034 (warning): CLEANUP_WT_CLEAR_DISPOSABLE appears unused. Verify use (or export if used externally).
```

### The variable is not actually unused

It is read across a `source` boundary that `shellcheck` cannot follow:

- `scripts/bash/cleanup_worktrees_dirt_lib.sh:59` — `CLEANUP_WT_CLEAR_DISPOSABLE=${CLEANUP_WT_CLEAR_DISPOSABLE:-0}`
- `scripts/bash/cleanup_worktrees_actions_lib.sh:347` — `((CLEANUP_WT_CLEAR_DISPOSABLE == 1)) || return 1`

So the diagnostic is a false positive about *usage*. It is nonetheless a true report of a real
defect, described next.

## The lint finding points at a genuine, measured coverage gap

`shellcheck` flagged the one line in this change whose effect no test observes.

### What is untested

The wrapper's flag pre-pass sets `CLEANUP_WT_CLEAR_DISPOSABLE=1` at
`scripts/bash/cleanup-worktrees.sh:145`. Nothing asserts that this assignment reaches
`delete_candidate`:

- `tests/shell/test_cleanup_worktrees_cli.bats:126` (`--apply --clear-disposable` and
  `--clear-disposable --apply` both dispatch to apply mode) drives the wrapper with the flag, but
  against the `merged_with_worktree` scenario. That worktree is CLEAN, so there is no dirt,
  `clear_disposable_dirt` is never reached, and the test asserts dispatch only.
- `tests/shell/test_cleanup_worktrees_dirt_clear.bats` exercises the clearing path against dirty
  scenarios, but sets `CLEANUP_WT_CLEAR_DISPOSABLE=1` directly in the environment
  (`:58`), bypassing the wrapper's pre-pass entirely. Its own header comment at `:10` records that
  tests 1 through 8 invoke `delete_candidate` DIRECTLY.

No test drives the wrapper with `--clear-disposable` over a dirty scenario.

### Measured, not inferred

The gap was confirmed by mutation rather than by reading. Line 145 was rewritten from
`CLEANUP_WT_CLEAR_DISPOSABLE=1` to `CLEANUP_WT_CLEAR_DISPOSABLE_TYPO=1`, which makes the
`--clear-disposable` flag incapable of ever arming the clearing path — the feature is dead.

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 0
Result: 22 `ok`, 0 `not ok`.

Both suites that own this behavior pass with the feature disabled. The wrapper was then restored
from a byte-identical backup and the restoration verified with `diff` (no output, exit 0).

### Why this is blocking rather than cosmetic

The acceptance criteria pin the classifier's verdicts and the clearing sequence thoroughly, and
those tests are sound. What they do not pin is that the user-facing flag reaches them. A shipped
`--clear-disposable` that silently never arms would pass every gate in this plan.

The direction of the failure is the safe one — the tool would decline to clear rather than clear
something it should not — so this is a correctness and usefulness defect, not a
destroy-user-work defect. It is still a feature that does not work and that no test would catch.

## Required remediation

1. Add a bats test that drives the wrapper end to end:
   `bash "${WRAPPER}" --apply --clear-disposable` against a dirty scenario whose dirt is entirely
   disposable (`dirt_clear_all_disposable`), asserting the clearing sequence actually runs.
2. Add the opposite direction: the same scenario through the wrapper WITHOUT `--clear-disposable`,
   asserting no `reset --hard` and no `clean -fd` appear. Both directions are required by this
   feature's standing quality obligation; the pair is what makes the assignment falsifiable.
3. Resolve SC2034. A blanket file-level disable is not acceptable. Prefer a form that keeps the
   diagnostic live for every other variable in the file.

## Gate status

P7-T2 fails, so the Phase 7 loop does not reach a single consecutive clean pass. P7-T3 through
P7-T8 were not run: the loop restarts from P7-T1 after remediation.
