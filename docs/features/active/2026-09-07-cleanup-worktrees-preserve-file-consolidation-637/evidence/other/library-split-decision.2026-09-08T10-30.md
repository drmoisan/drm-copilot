# Decision — both pre-authorized splits were taken at `[P5-T9]`

Timestamp: 2026-09-08T10-30
Task: `[P5-T9]`
Command: (decision record; the measurement it rests on is recorded in evidence/qa-gates/gate-library-line-cap.2026-09-08T10-30.md)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: both splits taken. New files: `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`
and `tests/shell/test_cleanup_worktrees_preserve_eol.bats`. Post-split counts 443 / 64 / 399 / 80.

## The library split — taken on the plan's own trigger

`scripts/bash/cleanup_worktrees_preserve_lib.sh` measured **489** lines at this task, above the
460 trigger `[P5-T9]` sets and eleven lines below the hard cap. The pre-authorized split moved the
line-ending and index group into `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`:

- `preserve_index_has_entry`
- `preserve_render_index_append`
- `preserve_derive_line_ending` (added to the new file by `[P6-T1]`; it did not yet exist at the
  moment of the split, exactly as `[P5-T9]` anticipates)

The new file is sourced immediately before the preserve library in
`scripts/bash/cleanup-worktrees.sh` and carries the same source-time guard as every sibling.

**One addition to the moved group, recorded rather than left implicit.** The per-record index
decision that consumes those three functions — resolving the destination index as the `MEMORY.md`
sibling of `target_path`, choosing between create, append, and duplicate, and selecting the
terminator — moves with them in Phase 6 as `preserve_plan_index`. It is the caller of the moved
group and is line-ending logic in substance, so leaving it behind would have split one decision
across two files and would have left the main library without the headroom the split exists to
create.

## The suite split — taken ahead of the plan's trigger, with the reason stated

`tests/shell/test_cleanup_worktrees_preserve.bats` measured **427** lines at this task, which is
**below** the 460 trigger. The split was taken anyway. The reason is forward-looking and
arithmetic rather than discretionary: Phase 6 adds four line-ending tests and Phase 7 adds four
host-token tests, eight tests whose combined size carries the file past the 500-line hard cap
before `[P9-T3]` next measures it. `[P9-T3]` does authorize the split at that later point, but
taking it there would mean knowingly creating a file that violates a hard repository rule for the
duration of Phases 7 through 9 and then rewriting every Phase 6 and Phase 7 gate artifact to name
the second file. Taking it here keeps every file inside the cap at all times and costs one
artifact instead of eight.

The specification's placement decision pre-authorizes this split without conditioning it on a line
count; the 460 figure is the plan's early-warning trigger, not the authorization. The delegation
governing this execution states the same, directing that both splits be taken if the cap requires
them.

**What moved.** The new suite `tests/shell/test_cleanup_worktrees_preserve_eol.bats` received the
two line-ending tests that already existed, so that all line-ending tests live in one file:

- `the crlf fixture still contains a carriage return in the working tree`
- `a stale advisory crlf value does not override an LF target`

Phase 6's four tests are authored there as well, per `[P5-T9]`.

**Consequence for two already-written artifacts, stated so the audit is not surprised.**
`evidence/qa-gates/gate-ac20-crlf-fixture.2026-09-08T09-49.md` and
`evidence/regression-testing/fail-before-stale-eol.2026-09-08T09-49.md` name
`tests/shell/test_cleanup_worktrees_preserve.bats` as the file holding those two tests, which was
true when they were written. Both tests keep their names, and the CI discharge locates a test by
its TAP `ok`/`not ok` line rather than by file, so neither discharge is affected. A relocation note
is appended to both artifacts.

## Task IDs affected, per `[P5-T9]`

| Task | Effect |
| --- | --- |
| `[P3-T6]`, `[P3-T8]` | The source-guard test gains a second case sourcing the line-ending library; `[P3-T8]` re-run and a fresh gate artifact written at this timestamp |
| `[P6-T1]` – `[P6-T5]` | Target `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh`; their acceptance searches that file |
| `[P6-T7]` | Authors its four tests in `tests/shell/test_cleanup_worktrees_preserve_eol.bats` |
| `[P6-T8]`, `[P6-T9]`, `[P6-T10]`, `[P7-T10]`, `[P7-T11]`, `[P7-T12]` | Name both suite files in the `bats` invocation, in the order preserve, then preserve_eol |
| `[P7-T9]` | Unaffected; continues to target `tests/shell/test_cleanup_worktrees_preserve.bats` |
| `[P9-T5]` | File list extended to both suite files |
| `[P4-T11]` | Suite-wide no-temporary-file acceptance extended to both suite files |
| `[P10-T7]` | Reads a `line-rate` for both libraries and records the covered-to-valid ratio across the two |

Verdict: both splits taken and recorded.
