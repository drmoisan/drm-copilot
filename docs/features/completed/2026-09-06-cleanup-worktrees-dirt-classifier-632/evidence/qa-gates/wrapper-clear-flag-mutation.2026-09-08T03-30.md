# Remediation of the P7-T2 finding: the flag pre-pass was unobserved, and the SC2034 suppression

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T02-35Z (nominal run-timestamp scheme, see
`evidence/regression-testing/pass-after-dirt-classify-full.2026-09-08T03-30.md`).
Run by: atomic-executor, directly. shellcheck 0.11.0 and bats 1.13.0 are both available in this
session, so every command below was executed first-hand rather than handed to the orchestrator.

## The finding

`shellcheck` reported SC2034 against `CLEANUP_WT_CLEAR_DISPOSABLE=1` in
`scripts/bash/cleanup-worktrees.sh`. The diagnostic is a false positive about usage: the variable
is read in `cleanup_worktrees_dirt_lib.sh` and in `cleanup_worktrees_actions_lib.sh`, across a
`source` boundary shellcheck does not follow. It nonetheless pointed at a real test gap. No test
observed that the assignment has any effect:

- `test_cleanup_worktrees_cli.bats` drove the wrapper with the flag against
  `merged_with_worktree`, which is clean, so `clear_disposable_dirt` was never reached and the
  test asserted dispatch only.
- `test_cleanup_worktrees_dirt_clear.bats` exercised clearing against dirty scenarios but set
  `CLEANUP_WT_CLEAR_DISPOSABLE=1` in the environment itself, bypassing the wrapper's pre-pass.

A shipped `--clear-disposable` that never armed would therefore have passed every gate in this
plan. The failure direction is the safe one — the tool declines to clear rather than clearing
something it should not — so this is a usefulness defect, not a destroy-user-work defect. It is
still an unfalsifiable feature.

## Remediation 1 — a wrapper-driven test pair

Added at the foot of `tests/shell/test_cleanup_worktrees_dirt_clear.bats`, with a
`wrapper_apply()` helper that invokes `bash "${WRAPPER}" --apply "$@"` under
`env -u CLEANUP_WT_CLEAR_DISPOSABLE`. The `env -u` matters: without it an ambient value would
make the no-flag direction unfalsifiable.

- `dirt_clear_all_disposable through the wrapper: --apply --clear-disposable arms the clearing
  sequence` asserts the `ACTION|dirt-clear|/repo-wt/dirt|OK` record and the ordering
  `reset --hard` < `clean -fd` < the second `worktree remove`.
- `dirt_clear_all_disposable through the wrapper: apply mode without the flag clears nothing`
  asserts, over the same scenario, that no `reset --hard` and no `clean -fd` appear, that no
  `ACTION|dirt-clear|` record is emitted, and that exactly one `worktree remove` is issued. Its
  positive control is `ACTION|worktree-remove|/repo-wt/dirt|BLOCKED-DIRTY`, which proves the run
  reached the removal and blocked on the same dirt the flagged run cleared, so the absence
  assertions are not passing because the run did nothing.

The two tests differ in the flag and in nothing else.

## Remediation 2 — mutation re-verification, run first-hand

The gap and the fix were both re-verified rather than taken on report.

Mutation: `scripts/bash/cleanup-worktrees.sh:153` rewritten from
`CLEANUP_WT_CLEAR_DISPOSABLE=1` to `CLEANUP_WT_CLEAR_DISPOSABLE_TYPO=1`, which makes the flag
incapable of arming the clearing path.

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_cli.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 1
ExpectedExitCode: 1

```
1..24
ok 1 ... ok 22   (all 22 pre-existing tests)
not ok 23 dirt_clear_all_disposable through the wrapper: --apply --clear-disposable arms the clearing sequence
# (in test file tests/shell/test_cleanup_worktrees_dirt_clear.bats, line 257)
#   `[[ "$output" == *'ACTION|dirt-clear|/repo-wt/dirt|OK'* ]]' failed
ok 24 dirt_clear_all_disposable through the wrapper: apply mode without the flag clears nothing
```

Two readings, both first-hand:

1. All 22 pre-existing tests report `ok` with the feature dead. That is the gap, confirmed by
   measurement rather than by inspection.
2. Exactly one test flips to `not ok`, and it is the new positive test. That is the fix, and it
   is the whole of the fix: the new negative test still passes under the mutation, which is
   correct, because it pins the direction in which nothing should happen. The pair is what makes
   the assignment falsifiable; neither test alone does.

Restoration: the file was restored from a byte-identical backup taken before the mutation.
Pre-mutation digest and post-restore digest are both
`8f3749a60949bdb3a27d7859ba3a9da65b8d608a29a7e0a48a02aefe5510dcb8`
(`sha256sum scripts/bash/cleanup-worktrees.sh`), and line 153 reads
`CLEANUP_WT_CLEAR_DISPOSABLE=1` again.

## Remediation 3 — the SC2034 suppression

Resolved with a line-scoped `# shellcheck disable=SC2034` on the line immediately above the
assignment, preceded by a comment recording the reason. `.claude/rules/shell.md` permits exactly
this form: "Suppressions are permitted only when justified inline with a
`# shellcheck disable=SCxxxx` comment stating the reason." A file-level blanket disable was
rejected because it would suppress SC2034 for every other variable in the file.

Justification recorded inline: the variable is read across a source boundary shellcheck does not
follow; the two reading sites are named; and the comment records that the assignment's effect is
pinned by the wrapper-driven pair, so the suppression does not hide an untested line.

`export` was considered and rejected as the alternative shellcheck itself suggests. The two
readers run in the same shell as the assignment, so no export is needed for correctness, and
exporting would additionally propagate the variable into every `git` child process the run
spawns. That is a wider blast radius than the defect requires.

### The suppression scope is itself falsifiable

Command: a copy of the post-fix wrapper was taken to the scratchpad, a second unused variable
`local UNUSED_SCOPE_PROBE=1` was inserted two lines above the suppressed assignment inside the
same `main` function, and shellcheck was run over the copy.

```
In .../probe.sh line 130:
	local UNUSED_SCOPE_PROBE=1
              ^----------------^ SC2034 (warning): UNUSED_SCOPE_PROBE appears unused.
```

EXIT_CODE: 1 on the probe copy. SC2034 still fires inside the same function two lines from the
suppressed line, which demonstrates the directive is line-scoped and not file-scoped. The probe
was performed on a scratchpad copy; the tracked file was never mutated for it.

## Post-remediation state

Command: `shellcheck -x scripts/bash/cleanup-worktrees.sh`
EXIT_CODE: 0

Command: `npx --yes bats tests/shell/test_cleanup_worktrees_dirt_clear.bats`
EXIT_CODE: 0 — 13 ok / 0 not ok (eleven pre-existing plus the two new).

Output Summary: the SC2034 finding is resolved with a line-scoped, justified suppression whose
narrowness was demonstrated by probe; the underlying test gap is closed by a wrapper-driven
positive/negative pair; and the pair was verified against the same mutation that exposed the gap,
with the mutation reverted and byte-identity confirmed by digest.
